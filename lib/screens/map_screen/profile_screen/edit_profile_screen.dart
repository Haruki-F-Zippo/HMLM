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
import 'package:google_fonts/google_fonts.dart'; // ★ League Spartan 用

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
  final TextEditingController _nameController = TextEditingController(); // 名前入力用のテキストコントローラ
  final TextEditingController _profileController = TextEditingController(); // プロフィール入力用のテキストコントローラ
  bool isLoading = false; // 「保存」ボタン押下時の処理中状態を示すフラグ

  @override
  void initState() { // 初期化処理。画面生成時に一度だけ呼ばれる。
    super.initState();

    // -------------------------------
    // 📝 デフォルト文言は「値」ではなくプレースホルダー扱いにする
    // -------------------------------
    _nameController.text =
    (widget.user.name == 'your name please!') ? '' : widget.user.name;

    _profileController.text =
    (widget.user.profile == 'your profile please!')
        ? ''
        : widget.user.profile;

    imageUrl = widget.user.imageUrl; // 既存ユーザーの画像URLを保持
  }

  void _setIsImageLoading(bool value) {
    setState(() {
      isImageLoading = value;
    });
  }

  void setImageUrl(String value) {
    setState(() {
      imageUrl = value;
    });
  }

  void _setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> pickImage(String userId) async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('カメラ'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('ギャラリー'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == null) {
      return;
    }

    final pickerFile = await ImagePicker().pickImage(source: source);
    if (pickerFile == null) {
      return;
    }
    File file = File(pickerFile.path);

    try {
      _setIsImageLoading(true);

      final TaskSnapshot task = await FirebaseStorage.instance
          .ref("users/${pickerFile.name}")
          .putFile(file);

      final url = await task.ref.getDownloadURL();

      setImageUrl(url);
    } catch (e) {
      print(e);
    } finally {
      _setIsImageLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900, // ロゴっぽく極太
            fontSize: 22,
            letterSpacing: 3,           // 文字間ひろめでブランド感アップ
            color: Colors.black,
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF93B5A5),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // アイコン画像編集
                    GestureDetector(
                      onTap: () => pickImage(widget.user.id!),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                        (imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                        child: isImageLoading
                            ? const AppLoading(color: Colors.blue)
                            : (imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 64)
                            : null),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === NAME フィールド ===
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'NAME',
                        hintText: 'your name please!',
                        floatingLabelBehavior: FloatingLabelBehavior
                            .always, // ← ラベルを常に上に表示する
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === PROFILE フィールド ===
                    TextField(
                      controller: _profileController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'PROFILE',
                        hintText: 'your profile please!',
                        alignLabelWithHint: true,
                        floatingLabelBehavior: FloatingLabelBehavior
                            .always, // ← ラベルを常に上に表示
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93B5A5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: isLoading
                  ? const AppLoading()
                  : const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    try {
      _setIsLoading(true);
      await FirebaseFirestore.instance
          .collection('app_users')
          .doc(widget.user.id)
          .update({
        'name': _nameController.text,
        'profile': _profileController.text,
        'image_url': imageUrl,
      });

      await Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      print(e);
    } finally {
      _setIsLoading(false);
    }
  }
}

// =============================
// 🧩 このファイル全体の説明（変更点）
// =============================
// - NAME / PROFILE フィールドに hintText を設定。
// - floatingLabelBehavior: FloatingLabelBehavior.always を指定して、
//   ラベル（NAME / PROFILE）は常に上部、hintText は未入力時だけ下に薄く表示。
// - これにより、ユーザーがタップする前から
//   「your name please!」「your profile please!」が見えて、
//   入力を始めた瞬間に自動で消える挙動になる。
