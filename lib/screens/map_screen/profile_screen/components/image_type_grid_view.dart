// import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
// import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
// import '../../../../image_type.dart'; // アプリ内で定義された画像タイプ（ImageType）enumをインポート
//
// class ImageTypeGridView extends StatelessWidget { // 画像タイプを選択するためのグリッドビューを定義するStatelessWidgetクラス
//   const ImageTypeGridView({ // コンストラクタ（キー、選択中の画像タイプ、タップ時の処理を受け取る）
//     super.key,
//     required this.selectedImageType, // 現在選択されているImageType
//     required this.onTap, // ImageTypeが選択された際に呼ばれるコールバック関数
//   });
//
//   // 現在選択されているImageType
//   final ImageType selectedImageType; // 現在の選択状態を保持する変数
//   // ImageTypeを返すコールバック関数
//   final ValueChanged<ImageType> onTap; // タップ時にImageTypeを返す関数型パラメータ
//
//   @override
//   Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
//     // enumの定数を配列で返す.values
//     const images = ImageType.values; // ImageTypeの全ての値をリストとして取得
//
//     // GridViewの定義
//     return GridView.count( // 固定カラム数のグリッドレイアウトを作成
//       crossAxisCount: 3, // 1行に表示するアイテム数を3つに設定
//       shrinkWrap: true, // コンテンツサイズに応じてGridViewの高さを自動調整
//       children: [
//         for (final imageType in images) // ImageTypeの各要素に対して以下を実行
//           GestureDetector( // タップイベントを検知するウィジェット
//             onTap: () => onTap(imageType), // タップされたときにコールバック関数を呼び出す
//             child: Padding( // アイテム間に余白を追加
//               padding: const EdgeInsets.all(8.0), // 8ピクセルのパディングを設定
//               child: CircleAvatar( // 円形の背景を持つウィジェットを作成
//                 // PaddingとbackgroundColorでボーダーを演出
//                 backgroundColor: imageType == selectedImageType // 現在選択されている画像タイプと一致しているかを判定
//                     ? Colors.blue // 選択中なら青いボーダーを表示
//                     : Colors.transparent, // 非選択時は背景を透明に設定
//                 child: Padding( // 内側に余白を設定
//                   padding: const EdgeInsets.all(3.0), // 3ピクセルのパディング
//                   child: Image.asset(imageType.path), // ImageTypeに定義されたパスの画像を表示
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// // =============================
// // 🧩 このファイル全体の説明
// // =============================
// // このファイルは、HMLMアプリ内でユーザーがプロフィール画像などの「ImageType」を選択するための
// // グリッド形式のUIコンポーネント「ImageTypeGridView」を定義している。
// // ImageType enum（例：ベルーガ、ライオン、クジラなど）を3列のGridViewで表示し、ユーザーがタップして選択できる。
// // 選択中の画像タイプは青いボーダーで強調表示され、視覚的に選択状態をわかりやすくしている。
// // onTapコールバックによって、選択結果（ImageType）が外部ウィジェットに通知される設計。
// // 主にプロフィール編集画面などでアバター選択UIとして使用される。
