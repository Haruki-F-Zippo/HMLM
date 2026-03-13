import 'dart:async'; // 非同期処理・ストリーム購読用の標準ライブラリ
import 'dart:ui';    // ★ ぼかし（BackdropFilter）に必要
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore操作用
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認証操作用
import 'package:flutter/cupertino.dart'; // iOSスタイルウィジェット
import 'package:flutter/material.dart'; // Materialデザインウィジェット
import 'package:geolocator/geolocator.dart'; // 位置情報取得・権限管理
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Googleマップ表示・制御
import 'package:googlemap_api/screens/map_screen/profile_screen/profile_screen.dart'; // プロフィール画面
import 'package:googlemap_api/screens/map_screen/setting_screen.dart'; // 設定画面
import 'package:googlemap_api/screens/map_screen/teach_screen.dart'; // TEACH画面（現状未使用かも）
import '../../models/app_user.dart'; // AppUserモデル（Firestoreとの橋渡し）
import '../teach/teach_post_draft_screen.dart';
import '../teach/teach_place_detail_screen.dart'; // TEACH詳細画面（別途実装）
import 'components/profile_button.dart'; // プロフィールFAB
import 'components/sign_in_button.dart'; // サインインFAB
import 'components/user_card_list.dart'; // ユーザーカードリスト（未使用コメントアウト中）
import 'hmlm_screen.dart'; // HMLM画面（プレースホルダ）
import 'manual_screen.dart'; // マニュアル画面（プレースホルダ）
import 'package:flutter/material.dart'; // 既存
import 'package:google_fonts/google_fonts.dart'; // ★ これを追加


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

//テスト
class _MapScreenState extends State<MapScreen> {
  late Position currentUserPosition; // 現在地（最新）を保持

  // ------------  Users  ------------
  // 他ユーザー位置リスナーは現在未使用のため削除
  late GoogleMapController mapController; // マップ制御用コントローラ
  late StreamSubscription<Position> positionStream; // 現在地ストリーム購読

  // 🗺 通常マーカー（現在地＋他ユーザー）※ 現在地はGoogle標準の青丸に任せる
  Set<Marker> markers = {}; // マップ上の全マーカー集合（今は主にTEACH以外があれば）

  // 🌿 TEACHスポット用マーカー
  Set<Marker> _teachMarkers = {};

  // TEACHスポット監視用ストリーム購読
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  _teachPlacesSubscription;

  final CameraPosition initialCameraPosition = const CameraPosition(
    // 初期カメラ位置：東京駅付近
    target: LatLng(35.681236, 139.767125),
    zoom: 16.0,
  );

  final LocationSettings locationSettings = const LocationSettings(
    // 現在地監視の設定
    accuracy: LocationAccuracy.high,
    distanceFilter: 20, // 20m移動でイベント発火
  );

  // ------------  Camera follow control  ------------
  static const Duration _cameraFollowInterval = Duration(minutes: 5);
  DateTime? _lastCameraFollowAt;

  // ------------  Auth  ------------
  late StreamSubscription<User?> authUserStream; // 認証状態リスナー
  String currentUserId = ''; // 現在ログイン中のuid
  bool isSignedIn = false; // ログイン状態フラグ

  // ------------  TEACH status  ------------
  bool _hasTeachPlace = false; // このユーザーがすでにTEACH登録しているか
  bool _isLoadingTeachStatus = true; // TEACH状態読み込み中かどうか

  // ------------  State changes  ------------
  void setIsSignedIn(bool value) {
    setState(() {
      isSignedIn = value;
    });
  }

  void setCurrentUserId(String value) {
    setState(() {
      currentUserId = value;
    });
  }

  void clearUserMarkers() {
    // （現在地はGoogle標準の青丸に任せるため）マーカーをすべてクリアでOK
    setState(() {
      markers.clear();
    });
  }

  @override
  void initState() {
    super.initState();

    // TEACHスポットの監視開始
    _watchTeachPlaces();

    // 初期化：認証監視とユーザー監視を開始
    _watchSignInState(); // 認証状態の監視開始
    // _watchUsers(); // Firestoreの他ユーザー位置を監視（現在は未使用）
    _loadTeachStatus(); // （サインイン済みであれば）TEACH状態を読み込み
  }

  @override
  void dispose() {
    // 後始末：各種ストリーム購読解除・コントローラ破棄
    mapController.dispose(); // マップコントローラ破棄
    positionStream.cancel(); // 現在地ストリーム解除
    authUserStream.cancel(); // 認証ストリーム解除
    _teachPlacesSubscription.cancel(); // TEACHスポット購読解除
    super.dispose();
  }

  // =======================
  // 🎨 汎用フェード画面遷移ヘルパー
  // =======================
  void _pushFade(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation, // 0.0 → 1.0 でフェードイン
            child: page,
          );
        },
      ),
    );
  }

  // ------------  TEACH状態取得  ------------
  Future<void> _loadTeachStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _hasTeachPlace = false;
        _isLoadingTeachStatus = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('teach_places')
          .doc(user.uid)
          .get();

      setState(() {
        _hasTeachPlace = doc.exists;
        _isLoadingTeachStatus = false;
      });
    } catch (_) {
      setState(() {
        _hasTeachPlace = false;
        _isLoadingTeachStatus = false;
      });
    }
  }

  // ------------  TEACHスポット監視（マーカー）  ------------
  void _watchTeachPlaces() {
    _teachPlacesSubscription = FirebaseFirestore.instance
        .collection('teach_places')
        .snapshots()
        .listen((snapshot) {
      // 🔑 今ログインしているユーザーのUID
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final teachMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final placeName = data['placeName'] as String? ?? 'TEACH PLACE';
        final ownerUserId = data['ownerUserId'] as String? ?? '';

        // 👇 ここで「自分のTEACHかどうか」を判定
        //   - teach_places の doc.id を ownerUserId として使っている前提
        final isMine = (currentUid != null && doc.id == currentUid);

        // 🎨 自分のTEACH：濃い緑 / 他ユーザーのTEACH：紺色（青系）
        // defaultMarkerWithHue は「色相のみ」指定できるので、
        // 濃い緑っぽい値として 120.0 を採用（Hue: 0=赤, 120=緑, 240=青あたり）。
        final double markerHue = isMine ? 120.0 : BitmapDescriptor.hueBlue;

        return Marker(
          markerId: MarkerId('teach_${doc.id}'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          infoWindow: InfoWindow(
            title: placeName,
            snippet: ownerUserId.isNotEmpty ? 'by $ownerUserId' : null,
          ),
          onTap: () {
            // タップで詳細画面へ（ここは既存どおりスライド遷移のまま）
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TeachPlaceDetailScreen(
                  placeId: doc.id, // teach_places の docId（= ownerUserId 想定）
                ),
              ),
            );
          },
        );
      }).toSet();

      setState(() {
        _teachMarkers = teachMarkers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色を透明にする（画面遷移時の白フラッシュ対策）
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // キーボード表示でレイアウトをずらさない
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(25),
        child: AppBar(
          backgroundColor: const Color(0xFF93B5A5),
          elevation: 4,
          surfaceTintColor: Colors.transparent, // ★ Material3の色かぶり防止
          automaticallyImplyLeading: false,
          // ★ ここで境界のぼかしを追加
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.transparent),
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HMLM',
              style: GoogleFonts.leagueSpartan(
                fontWeight: FontWeight.w900,
                fontSize: 25,
                letterSpacing: 3, // ← ちょっと広げてロゴ感アップ
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        // マップの上にUIを重ねるためStackを使用
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            // ① Googleマップ本体
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) async {
              // マップ生成時
              mapController = controller; // コントローラ保持
              await _requestPermission(); // 位置権限の確認・要求
              await _moveToCurrentLocation(); // 現在地へカメラ移動
              _watchCurrentLocation(); // 現在地の継続監視開始
            },
            myLocationButtonEnabled: false,
            myLocationEnabled:
            true, // 🔵 Google標準の「青い現在地アイコン」を表示する
            // 🗺 通常マーカー + TEACHマーカー をまとめて表示
            markers: {
              ...markers,
              ..._teachMarkers,
            },
          ),

          // ② 画面中央固定の📍アイコン
          const IgnorePointer(
            child: Center(
              child: Icon(
                Icons.place,
                size: 36,
                color: Colors.red,
              ),
            ),
          ),

          // ③ FirestoreのAppUser（全体）を監視してUIを更新
          StreamBuilder(
            stream: getAppUsersStream(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData && isSignedIn) {
                final users = snapshot.data!
                    .where((user) => user.id != currentUserId)
                    .where((user) => user.location != null)
                    .toList();

                // 将来、ユーザーカードを表示したいときに復活させる
                // return UserCardList(
                //   onPageChanged: (index) { ... },
                //   appUsers: users,
                // );
              }
              return Container();
            },
          ),
        ],
      ),

      // =======================
      // 🔘 サインイン状態別のFAB
      // =======================
      floatingActionButtonLocation: !isSignedIn
          ? FloatingActionButtonLocation.centerFloat // 未ログイン時：中央下
          : FloatingActionButtonLocation.endTop, // ログイン時：右上寄り
      floatingActionButton: !isSignedIn
          ? SignInButton(
        // サインインを促すFAB
        onSignedIn: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _ensureAppUserDocument(user);
            await _loadTeachStatus(); // サインイン後にTEACH状態を更新
          }
          if (mounted) setState(() {});
        },
      )
          : Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: ProfileButton(
          // プロフィール画面へ遷移するFAB（フェード遷移）
          onPressed: () {
            _pushFade(const ProfileScreen());
          },
        ),
      ),

      // =======================
      // ⬇ 画面下部のタブナビゲーション
      // =======================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // この画面はHMLM（index 1）
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
            // TEACH / DELETE タブ
              _onTeachPressed();
              break;
            case 1:
            // HMLMタブ → フェードでHmlmScreenへ
              _pushFade(const HmlmScreen());
              break;
            case 2:
            // MANUALタブ → フェードでManualScreenへ
              _pushFade(const ManualScreen());
              break;
            case 3:
            // SETTINGタブ → フェードでSettingScreenへ
              _pushFade(const SettingScreen());
              break;
          }
        },
        items: _buildBottomNavItems(), // ★ TEACH / DELETE を動的に切り替え
      ),
    );
  }

  /// 🔘 BottomNavigationBar の項目を状態に応じて生成
  List<BottomNavigationBarItem> _buildBottomNavItems() {
    // TEACH 1件持っている & ローディング完了 なら DELETE モード
    final isDeleteMode = isSignedIn && !_isLoadingTeachStatus && _hasTeachPlace;
    final teachLabel = isDeleteMode ? 'DELETE' : 'TEACH';

    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.school),
        label: teachLabel,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'HMLM',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.menu_book),
        label: 'MANUAL',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'SETTING',
      ),
    ];
  }

  // =======================
  // 🔧 TEACH / DELETE ボタン押下時の挙動
  // =======================
  Future<void> _onTeachPressed() async {
    // 未ログインならTEACHは使わせない
    if (!isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('「TEACH」を利用するにはサインインしてください')),
      );
      return;
    }

    if (_isLoadingTeachStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TEACH情報を読み込み中です…')),
      );
      return;
    }

    // すでに1つTEACHを持っている → DELETE フロー
    if (_hasTeachPlace) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text('登録した情報を本当に削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        await _deleteMyTeachPlace();
      }
      return;
    }

    // ここから「新規TEACH登録」フロー
    final centerLatLng = await _getMapCenterLatLng();
    if (centerLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('地図の中心座標が取得できませんでした')),
      );
      return;
    }

    // 場所登録入力画面へ遷移（ここは従来どおりスライド遷移のまま）
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeachPostDraftScreen(
          initialLatLng: centerLatLng,
        ),
      ),
    );

    // TeachPostDraftScreen 側で SAVE 成功時に true を返してもらう想定
    if (result == true) {
      _loadTeachStatus();
    }
  }

  /// 自分のTEACH登録を削除するヘルパー
  Future<void> _deleteMyTeachPlace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('teach_places')
          .doc(user.uid)
          .delete();

      if (!mounted) return;

      setState(() {
        _hasTeachPlace = false; // → TEACHボタン復活
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TEACHの登録を削除しました')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除に失敗しました。時間をおいて再度お試しください。')),
      );
    }
  }

  // 地図中央の LatLng を取得するヘルパー（ズレ改善版）
  Future<LatLng?> _getMapCenterLatLng() async {
    try {
      final mq = MediaQuery.of(context);

      // 画面全体サイズ
      final double fullWidth  = mq.size.width;
      final double fullHeight = mq.size.height;

      // 端末のセーフエリア分
      final double paddingTop    = mq.padding.top;
      final double paddingBottom = mq.padding.bottom;

      // AppBar / BottomNav の高さ
      const double appBarHeight    = 25.0;
      const double bottomNavHeight = kBottomNavigationBarHeight;

      // 実際に GoogleMap が描画されている領域の高さ
      final double mapHeight =
          fullHeight - paddingTop - paddingBottom - appBarHeight - bottomNavHeight;

      // 🔴 赤ピンと完全に同じ「表示されている地図領域の中心」
      final screenCoordinate = ScreenCoordinate(
        x: (fullWidth / 2).round(),
        y: (mapHeight / 2).round(),
      );

      final latLng = await mapController.getLatLng(screenCoordinate);
      return latLng;
    } catch (_) {
      return null;
    }
  }


  Future<void> _ensureAppUserDocument(User user) async {
    // Firestore上のユーザードキュメントを作成/更新
    final ref =
    FirebaseFirestore.instance.collection('app_users').doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'name': user.displayName ?? '',
        'profile': '',
        'image_url': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'updatedAt': FieldValue.serverTimestamp(),
        if (user.displayName != null) 'name': user.displayName,
        if (user.photoURL != null) 'image_url': user.photoURL,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _requestPermission() async {
    // 位置情報権限の確認と要求
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _moveToCurrentLocation() async {
    // 現在地取得→カメラ移動（マーカーは追加しない：Google標準の青丸に任せる）
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  void _watchCurrentLocation() {
    // 位置更新ストリーム購読→Firestore更新。
    // カメラ追従は「5分に1回まで」に制限して、
    // ユーザーの手動操作中に勝手に戻り続ける挙動を防ぐ。
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) async {
          currentUserPosition = position;

          // マーカーは更新しない（Google標準の青丸に任せる）

          await _updateUserLocationInFirestore(position);

          final now = DateTime.now();
          final canAutoFollow =
              _lastCameraFollowAt == null ||
              now.difference(_lastCameraFollowAt!) >= _cameraFollowInterval;

          if (canAutoFollow) {
            await mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: await mapController.getZoomLevel(),
                ),
              ),
            );
            _lastCameraFollowAt = now;
          }
        });
  }

  // ------------  Methods for Auth  ------------
  void _watchSignInState() {
    // 認証状態のリアルタイム監視
    authUserStream =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user == null) {
            // サインアウト時
            setIsSignedIn(false);
            setCurrentUserId('');
            clearUserMarkers();
            setState(() {
              _hasTeachPlace = false;
              _isLoadingTeachStatus = false;
            });
          } else {
            // サインイン時
            setIsSignedIn(true);
            setCurrentUserId(user.uid);
            // await setUsers(); // 現在は未使用
            _loadTeachStatus(); // サインインしたらTEACH状態を読み込み
          }
        });
  }

  // ------------  Methods for Firestore  ------------
  Future<void> _updateUserLocationInFirestore(Position position) async {
    if (isSignedIn) {
      await FirebaseFirestore.instance
          .collection('app_users')
          .doc(currentUserId)
          .update({
        'location': GeoPoint(
          position.latitude,
          position.longitude,
        ),
      });
    }
  }

  Future<List<AppUser>> getAppUsers() async {
    // 全ユーザーのスナップショットを1回取得
    return await FirebaseFirestore.instance.collection('app_users').get().then(
          (snps) =>
          snps.docs.map((doc) => AppUser.fromDoc(doc.id, doc.data())).toList(),
    );
  }

  Stream<List<AppUser>> getAppUsersStream() {
    // 全ユーザーのリアルタイムストリーム
    return FirebaseFirestore.instance.collection('app_users').snapshots().map(
          (snp) =>
          snp.docs.map((doc) => AppUser.fromDoc(doc.id, doc.data())).toList(),
    );
  }

// ------------  Methods for Markers  ------------
// 他ユーザー位置マーカー関連は現在未使用のためコメントアウトのまま
// void _watchUsers() { ... }
// Future<void> setUsers() async { ... }
// void _setUserMarkers(List<AppUser> users) { ... }
}

// =============================
// 🧩 このファイル全体の説明（変更ポイント）
// =============================
// ・teach_places を購読し、ログイン中ユーザーの UID と teach_places の doc.id を比較して
//   「自分のTEACH」と「他ユーザーのTEACH」を判定。
// ・自分のTEACHは hue=120.0（濃い緑寄り）、他ユーザーのTEACHは BitmapDescriptor.hueBlue（紺っぽい青）で表示。
// ・現在地表示は GoogleMap 標準の「青い現在地アイコン」に任せ、HMLM側では current_location マーカーを出さない。
// ・BottomNavigationBar の TEACH / DELETE 切り替え、フェード遷移など既存の挙動はそのまま維持。
