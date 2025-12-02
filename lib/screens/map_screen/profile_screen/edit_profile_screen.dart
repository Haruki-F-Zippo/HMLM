import 'dart:io'; // 画像ファイルを扱うためのdart標準ライブラリをインポート
import 'dart:ui'; // ← ガラス風ぼかしに必要（BackdropFilter）を使用するためのライブラリをインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestoreを使用するためのパッケージをインポート
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storageを使用するためのパッケージをインポート
import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
import 'package:image_picker/image_picker.dart'; // 端末のカメラやギャラリーから画像を取得するためのパッケージをインポート
import '../../../components/app_loading.dart'; // 共通のローディングインジケータウィジェットをインポート
import '../../../image_type.dart'; // 画像タイプ（enum ImageType）の定義をインポート
import '../../../models/app_user.dart'; // Firestore上のユーザーデータモデルAppUserをインポート
import 'components/image_type_grid_view.dart'; // プロフィール画像選択用グリッドビューコンポーネントをインポート

class EditProfileScreen extends StatefulWidget { // プロフィールを編集する画面を定義するStatefulWidgetクラス
  const EditProfileScreen({ // コンストラクタ（キーとユーザーデータを受け取る）
    super.key,
    required this.user, // 編集対象のユーザー情報
  });

  final AppUser user; // Firestoreから取得したユーザー情報を保持する変数

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState(); // Stateクラスを生成して返す
}

class _EditProfileScreenState extends State<EditProfileScreen> { // プロフィール編集画面の状態を管理するクラス
  String imageUrl = ''; // 表示またはアップロード後のユーザー画像URLを保持する変数
  bool isImageLoading = false; // 画像アップロード中かどうかを示すフラグ
  //ImageType selectedImageType = ImageType.lion; // 選択された画像タイプ（デフォルトはライオン）
  final TextEditingController _nameController = TextEditingController(); // 名前入力用のテキストコントローラ
  final TextEditingController _profileController = TextEditingController(); // プロフィール入力用のテキストコントローラ
  bool isLoading = false; // 「保存」ボタン押下時の処理中状態を示すフラグ

  @override
  void initState() { // 初期化処理。画面生成時に一度だけ呼ばれる。
    _nameController.text = widget.user.name; // 既存ユーザーの名前をテキストフィールドに反映
    _profileController.text = widget.user.profile; // 既存ユーザーのプロフィールをテキストフィールドに反映
    imageUrl = widget.user.imageUrl; // 既存ユーザーの画像URLを保持
    super.initState(); // 親クラスの初期化処理を実行
  }

  void _setIsImageLoading(bool value) { // 画像アップロード状態を更新する関数
    setState(() {
      isImageLoading = value; // trueでアップロード中、falseで完了
    });
  }

  void setImageUrl(String value) { // 画像URLを更新する関数
    setState(() {
      imageUrl = value; // 新しいURLをstateに保存
    });
  }

  // void _setImageType(ImageType imageType) { // 選択された画像タイプを更新する関数
  //   setState(() {
  //     selectedImageType = imageType; // 新しいImageTypeをstateに保存
  //   });
  // }

  void _setIsLoading(bool value) { // プロフィール保存時のローディング状態を更新する関数
    setState(() {
      isLoading = value; // trueで処理中、falseで完了
    });
  }
  Future<void> pickImage(String userId) async { // ユーザーのプロフィール画像を端末から選択・アップロードする非同期関数

    // 1. 画像のソースを選択する
    final source = await showModalBottomSheet<ImageSource?>( // カメラまたはギャラリーの選択モーダルを表示
      context: context, // 現在のBuildContextを指定
      builder: (context) => Column( // モーダルの中身を縦方向に並べる
        mainAxisSize: MainAxisSize.min, // 内容の高さに合わせてモーダルサイズを最小化
        children: [
          ListTile( // 「カメラで撮影」を選択するボタン
            leading: const Icon(Icons.camera), // カメラアイコンを表示
            title: const Text('カメラ'), // テキスト「カメラ」を表示
            onTap: () => Navigator.of(context).pop(ImageSource.camera), // 押下時にモーダルを閉じてカメラソースを返す
          ),
          ListTile( // 「ギャラリーから選択」を選択するボタン
            leading: const Icon(Icons.photo), // ギャラリーアイコンを表示
            title: const Text('ギャラリー'), // テキスト「ギャラリー」を表示
            onTap: () => Navigator.of(context).pop(ImageSource.gallery), // 押下時にモーダルを閉じてギャラリーソースを返す
          ),
        ],
      ),
    );
    // ※選択されずにモーダルを閉じた場合、後続処理を行わない
    if (source == null) { // ソースが選択されなかった場合
      return; // 処理を終了
    }

    // 2. imagePickerで画像を取得する
    final pickerFile = await ImagePicker().pickImage(source: source); // カメラまたはギャラリーから画像を取得
    if (pickerFile == null) { // 画像が選択されなかった場合
      return; // 処理を終了
    }
    File file = File(pickerFile.path); // 選択された画像パスからFileオブジェクトを生成

    try {
      _setIsImageLoading(true); // 画像アップロード中フラグをtrueに設定（ローディング表示）

      // 3. Cloud Storageに画像をアップロードする
      final TaskSnapshot task = await FirebaseStorage.instance // Firebase Storageインスタンスを取得
          .ref("users/${pickerFile.name}") // 保存先のパスを指定（users/ファイル名）
          .putFile(file); // 画像ファイルをアップロード

      // 4. ダウンロードURLを取得する
      final url = await task.ref.getDownloadURL(); // アップロード完了後、画像の公開URLを取得

      // 5. 取得したURLを変数に代入
      setImageUrl(url); // State内のimageUrlを更新し、画面上の画像を変更

    } catch (e) { // 例外発生時の処理
      print(e); // エラー内容をコンソールに出力
    } finally {
      _setIsImageLoading(false); // アップロード完了後、ローディング状態を解除
    }
  }
  @override
  Widget build(BuildContext context) { // 画面のUIを構築するbuildメソッド
    return Scaffold( // Materialデザインの基本構造を提供するウィジェット
      appBar: AppBar( // 画面上部のAppBar（タイトルバー）を定義
        title: const Text( // タイトルテキストを設定
          'EDIT PROFILE', // 画面タイトル「EDIT PROFILE」
          style: TextStyle(
            fontWeight: FontWeight.bold, // ← 太字を追加
            color: Colors.black, // ← 黒文字で視認性アップ
          ),
        ),
        elevation: 4, // 軽い影をつけて立体感を出す
        // 軽いシャドウ
        backgroundColor: const Color(0xFF93B5A5), // ← AppBarの色を #93B5A5 に変更（HMLMテーマカラー）
        // ← AppBarの色を #93B5A5 に変更
        surfaceTintColor: Colors.transparent, // Material3特有のティント効果を無効化
        // Material3の自動ティント無効化
        // ぼかしは AppBar 範囲に限定
        flexibleSpace: ClipRect( // ぼかしをAppBar範囲に限定するためのウィジェット
          child: BackdropFilter( // ガラス風のぼかし効果を適用
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // ぼかし量（横12・縦12）
            child: Container(color: Colors.transparent), // 背景を透明に設定
          ),
        ),
      ),
      backgroundColor: Colors.white, // ← 画面背景を白に変更
      body: Container( // 画面本体のコンテナ
        padding: const EdgeInsets.all(20), // 四方に20ピクセルの余白を設定
        child: Column( // 縦方向にウィジェットを配置
          children: [
            Expanded( // スクロール領域を画面内で拡張
              child: SingleChildScrollView( // コンテンツを縦スクロール可能にする
                child: Column( // スクロール内の要素を縦方向に並べる
                  children: [
                    // アイコン画像
                    // アイコン画像編集
                    GestureDetector( // タップ検知ウィジェット（画像タップで変更可能にする）
                      onTap: () => pickImage(widget.user.id!), // 画像をタップした際に画像選択処理を呼び出す
                      child: CircleAvatar( // 円形のプロフィール画像を表示
                        radius: 100, // 直径200ピクセルの大きな円形領域
                        backgroundColor: Colors.transparent, // 背景を透明に設定
                        backgroundImage: (imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null, // Firestoreから取得した画像URLがある場合に表示
                        child: isImageLoading // アップロード中かどうかで表示を切り替える
                            ? const AppLoading(color: Colors.blue) // ローディング中は青色のローディングインジケータを表示
                            : (imageUrl.isEmpty ? const Icon(Icons.person, size: 64) : null), // 画像がない場合は人型アイコンを表示
                      ),
                    ),
                    // ユーザー名のテキストフィールド
                    TextField( // 名前入力用のテキストフィールド
                      decoration: const InputDecoration(labelText: 'NAME'), // フィールド上に「NAME」とラベルを表示
                      controller: _nameController, // 入力内容を管理するコントローラ
                    ),
                    // プロフィール詳細のテキストフィールド
                    TextField( // プロフィール詳細入力用のテキストフィールド
                      maxLines: 5, // 最大5行まで入力可能
                      decoration: const InputDecoration(labelText: 'PROFILE'), // フィールド上に「PROFILE」とラベルを表示
                      controller: _profileController, // 入力内容を管理するコントローラ
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton( // 「SAVE」ボタンを定義
              onPressed: updateProfile, // ボタン押下時にupdateProfile関数を実行
              style: ElevatedButton.styleFrom( // ボタンのスタイルを指定
                backgroundColor: Color(0xFF93B5A5), // 背景色をテーマカラーに設定
                shape: RoundedRectangleBorder( // ボタン形状の指定
                  borderRadius: BorderRadius.circular(8), // 角を8ピクセル丸める
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12), // 内側余白を設定
              ),
              child: isLoading // ローディング中かどうかで表示内容を切り替え
                  ? const AppLoading() // 保存処理中はローディングインジケータを表示
                  : const Text( // 通常時のテキスト
                'SAVE', // ボタンラベル
                style: TextStyle(
                  color: Colors.white, // ← 文字色を白に
                  fontWeight: FontWeight.bold, // 太字で強調
                  letterSpacing: 1.2, // 文字間隔を少し広げる
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    // Firestore上のユーザーデータを更新する非同期関数
    try {
      _setIsLoading(true); // 保存処理中フラグをtrueに設定（ローディング表示）
      await FirebaseFirestore.instance // Firestoreインスタンスを取得
          .collection('app_users') // 「app_users」コレクションを指定
          .doc(widget.user.id) // 編集対象のユーザーIDのドキュメントを指定
          .update({ // Firestore上のデータを更新
        'name': _nameController.text, // 名前を入力フィールドの値で更新
        'profile': _profileController.text, // プロフィールを入力フィールドの値で更新
        //'image_type': selectedImageType.name, // 選択されている画像タイプを更新
        'image_url': imageUrl, // アップロード済みの画像URLを更新
      });

      await Future.delayed(const Duration(seconds: 1), () { // 少し遅延を入れてUI反映を安定化
        Navigator.of(context).pop(); // プロフィール更新完了後に画面を閉じる
      });
    } catch (e) { // 例外処理
      print(e); // エラー内容をコンソールに出力
    } finally {
      _setIsLoading(false); // ローディング状態を解除
    }
  }
  }

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリの「プロフィール編集画面（EditProfileScreen）」を実装している。
// - 画面構成：AppBar（#93B5A5＋ガラス風ぼかし）／本文（アイコン画像・名前・プロフィール入力・SAVEボタン）
// - 画像変更：画像をタップ→カメラ or ギャラリーを選択（showModalBottomSheet + ImagePicker）→
//             Firebase Storage にアップロード→ダウンロードURLを取得→stateの imageUrl を更新して即時反映。
// - 入力項目：TextFieldで name / profile を編集（TextEditingControllerで状態管理）。
// - 保存処理：SAVE押下で Firestore の「app_users/{userId}」を更新（name / profile / image_type / image_url）。
// - 状態管理：isLoading（保存中インジケータ表示）、isImageLoading（画像アップロード中インジケータ表示）。
// - 補助：AppLoading（共通ローディングUI）、ImageType（アバター種別）、ImageTypeGridView（画像タイプUIコンポーネントを利用可能）。
// これにより、ユーザーは1画面でプロフィール画像の変更からテキスト編集、保存まで一貫して行える。
