import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのデータ型（GeoPointなど）を使用するためのパッケージをインポート
import '../image_type.dart'; // 画像タイプ関連の定義をインポート（同ディレクトリの上階層にあるファイル）

const String blankImage = // デフォルト画像URL（ユーザー画像が未設定の場合に使用）
    'https://firebasestorage.googleapis.com/v0/b/gs-expansion-test.appspot.com/o/unknown_person.png?alt=media';


class AppUser { // アプリ内のユーザーデータを表すモデルクラス
  AppUser({ // コンストラクタ（初期値を指定できる）
    this.id, // Firestore上のドキュメントID
    this.name = '', // ユーザー名（デフォルト空文字）
    this.profile = '', // プロフィール情報（デフォルト空文字）
    this.location, // 位置情報（GeoPoint型、任意）
    this.imageUrl = blankImage, // ユーザー画像のURL（未設定時はデフォルト画像）
  });

  final String? id; // Firestore上のドキュメントID（nullable）
  final String name; // ユーザー名
  final String profile; // プロフィールテキスト
  final GeoPoint? location; // Firestoreで位置情報を扱うためのGeoPointオブジェクト
  final String imageUrl; // ユーザー画像のURL

  factory AppUser.fromDoc(String id, Map<String, dynamic> json) => AppUser( // FirestoreのドキュメントデータからAppUserを生成するファクトリコンストラクタ
    id: id, // ドキュメントIDを設定
    name: json['name'], // Firestoreの"name"フィールドを取得
    profile: json['profile'], // Firestoreの"profile"フィールドを取得
    location: json['location'], // Firestoreの"location"フィールド（GeoPoint型）を取得
    imageUrl: json['image_url'] ?? blankImage, // "image_url"が存在すれば使用、なければデフォルト画像を設定
  );

  /// 未登録ユーザー用の空データ
  factory AppUser.empty({String? id}) { // 新規ユーザーや未登録状態のユーザー用に空データを生成するファクトリコンストラクタ
    return AppUser(
      id: id, // 任意のIDを設定
      name: '', // 空文字のユーザー名
      profile: '', // 空文字のプロフィール
      imageUrl: '', // 空の画像URL
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリにおけるユーザーデータモデル「AppUser」を定義している。
// Firestoreのドキュメントデータをアプリ内で扱いやすい形に変換し、ユーザー名・プロフィール・位置情報・画像URLを保持する。
// fromDoc()ファクトリでFirestoreのデータからインスタンスを生成し、empty()で未登録ユーザー用の空データを生成できる。
// また、画像が未設定の場合に使用されるデフォルト画像（blankImage）のURLも定義されている。
// このモデルはFirestore連携機能やプロフィール画面など、ユーザー関連のあらゆる機能で利用される。
