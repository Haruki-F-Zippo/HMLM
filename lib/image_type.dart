// enum ImageType { // ← 画像の種類を列挙する enum（列挙型）を定義
//   lion, // ← ライオンの画像タイプ
//   raqoon, // ← アライグマ（Raccoon）の画像タイプ（※綴りは "raccoon" が正しいがそのまま使用）
//   rabbit, // ← ウサギの画像タイプ
//   monkey, // ← サルの画像タイプ
//   panda, // ← パンダの画像タイプ
//   dog; // ← イヌの画像タイプ
//
//   static ImageType fromString(String type) { // ← 文字列から対応する ImageType を取得する静的メソッド
//     switch (type) { // ← 入力された文字列に応じて分岐
//       case 'lion': // ← "lion" の場合
//         return ImageType.lion; // ライオンタイプを返す
//       case 'raqoon': // ← "raqoon" の場合
//         return ImageType.raqoon; // アライグマタイプを返す
//       case 'rabbit': // ← "rabbit" の場合
//         return ImageType.rabbit; // ウサギタイプを返す
//       case 'monkey': // ← "monkey" の場合
//         return ImageType.monkey; // サルタイプを返す
//       case 'panda': // ← "panda" の場合
//         return ImageType.panda; // パンダタイプを返す
//       case 'dog': // ← "dog" の場合
//         return ImageType.dog; // イヌタイプを返す
//       default: // ← どれにも一致しない場合
//         return ImageType.lion; // デフォルトでライオンを返す
//     }
//   }
//
//   get path { // ← 各 ImageType に対応する画像ファイルパスを返す getter
//     switch (this) { // ← 現在の enum の値に応じて分岐
//       case ImageType.lion: // ← ライオンの場合
//         return 'assets/images/lion.png'; // 対応する画像パスを返す
//       case ImageType.raqoon: // ← アライグマの場合
//         return 'assets/images/raqoon.png'; // 対応する画像パスを返す
//       case ImageType.rabbit: // ← ウサギの場合
//         return 'assets/images/rabbit.png'; // 対応する画像パスを返す
//       case ImageType.monkey: // ← サルの場合
//         return 'assets/images/monkey.png'; // 対応する画像パスを返す
//       case ImageType.panda: // ← パンダの場合
//         return 'assets/images/panda.png'; // 対応する画像パスを返す
//       case ImageType.dog: // ← イヌの場合
//         return 'assets/images/dog.png'; // 対応する画像パスを返す
//       default: // ← 想定外の値（保険として）
//         return 'assets/images/lion.png'; // デフォルトでライオン画像を返す
//     }
//   }
// }
//
// // =============================
// // 🧩 このファイル全体の説明
// // =============================
// // このファイルは、アプリで使用するキャラクター画像（動物アイコン）を管理するための enum（列挙型）を定義している。
// // ■ 主な役割：
// // ・`ImageType`：ライオン、アライグマ、ウサギ、サル、パンダ、イヌなどの画像タイプを識別。
// // ・`fromString()`：文字列（例："panda"）から対応する ImageType を返す静的メソッド。
// // ・`path`：それぞれの ImageType に対応するアセット画像パス（assets/images/*.png）を返す getter。
// //
// // ■ 使用例：
// //   ```dart
// //   ImageType type = ImageType.fromString("panda");
// //   print(type.path); // => 'assets/images/panda.png'
// //   ```
// //
// // この仕組みにより、データベースやJSONなどに保存された文字列から、対応する画像アセットを簡単に呼び出すことができる。
