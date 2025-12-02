// import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
// import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
// import '../../../models/app_user.dart'; // Firestore上のユーザーデータを表すAppUserモデルをインポート
//
// class UserCardList extends StatefulWidget { // 複数ユーザー情報を横スワイプで表示するカードリストウィジェット
//   const UserCardList({ // コンストラクタ（キー、ページ変更コールバック、ユーザーリストを受け取る）
//     super.key,
//     required this.onPageChanged, // ページ切り替え時に呼ばれるコールバック関数
//     required this.appUsers, // 表示するユーザー(AppUser)リスト
//   });
//
//   final void Function(int)? onPageChanged; // ページ変更時にインデックスを受け取る関数
//   final List<AppUser> appUsers; // 表示対象のユーザーリスト
//
//   @override
//   State<UserCardList> createState() => _UserCardListState(); // Stateクラスを生成
// }
//
// class _UserCardListState extends State<UserCardList> { // ユーザーカードリストの状態を管理するクラス
//   final PageController _pageController = PageController( // ページ表示を制御するコントローラ
//     viewportFraction: 0.8, // ページ幅を80%に設定（隣のカードが少し見えるデザイン）
//   );
//
//   @override
//   Widget build(BuildContext context) { // UIを構築するbuildメソッド
//     return Container( // レイアウト用のコンテナ
//       height: 200, // コンテナの高さを200に設定
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 20), // 下部に20ピクセルの余白を設定
//       child: PageView( // ページスワイプ可能なウィジェット
//         onPageChanged: widget.onPageChanged, // ページ変更時の処理を指定
//         controller: _pageController, // ページ制御用コントローラを指定
//         children: [
//           Container(), // 最初のページに空のコンテナ（スペーサー的な役割）
//           for (final AppUser appUser in widget.appUsers) // appUsersリスト内の各ユーザーに対してカードを生成
//             UserCard(appUser: appUser), // 個別のユーザーカードを表示
//         ],
//       ),
//     );
//   }
// }
//
// class UserCard extends StatelessWidget { // 単一ユーザーの情報を表示するカードウィジェット
//   const UserCard({ // コンストラクタ（キーとAppUserデータを受け取る）
//     super.key,
//     required this.appUser, // 表示するユーザー情報
//   });
//
//   final AppUser appUser; // ユーザーデータ（名前・プロフィール・画像など）
//
//   @override
//   Widget build(BuildContext context) { // UIを構築するbuildメソッド
//     return Container( // レイアウト用のコンテナ
//       height: 100, // コンテナの高さを100に設定
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 20), // 下部に20ピクセルの余白を設定
//       child: Card( // マテリアルデザインのカードウィジェット
//         elevation: 4, // 影をつけて浮き上がって見える効果を設定
//         shape: RoundedRectangleBorder( // カードの角を丸める設定
//           borderRadius: BorderRadius.circular(20), // 角丸を20ピクセルに設定
//         ),
//         child: Padding( // カード内部に余白を設定
//           padding: const EdgeInsets.all(16), // 四方に16ピクセルの余白を追加
//           child: Row( // 横並びレイアウト
//             children: [
//               CircleAvatar( // ユーザー画像を円形で表示
//                 radius: 40, // 画像の半径を40ピクセルに設定
//                 backgroundImage: NetworkImage(appUser.imageUrl), // Firestore上のURLから画像を読み込み
//               ),
//               const SizedBox(width: 12), // 画像とテキストの間に12ピクセルの間隔を追加
//               Expanded( // テキスト部分を可変幅で配置
//                 child: Column( // 名前とプロフィールを縦方向に並べる
//                   crossAxisAlignment: CrossAxisAlignment.start, // 左寄せで配置
//                   children: [
//                     Text( // ユーザー名を表示
//                       appUser.name, // AppUserモデルのnameを参照
//                       style: const TextStyle( // テキストのスタイル設定
//                         fontWeight: FontWeight.bold, // 太字に設定
//                         fontSize: 20, // フォントサイズを20に設定
//                       ),
//                     ),
//                     const SizedBox(height: 8), // 名前とプロフィールの間に8ピクセルの余白を追加
//                     Text( // プロフィール文を表示
//                       appUser.profile, // AppUserモデルのprofileを参照
//                       maxLines: 4, // 最大4行まで表示
//                       overflow: TextOverflow.ellipsis, // 文字が長い場合は「…」で省略
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // =============================
// // 🧩 このファイル全体の説明
// // =============================
// // このファイルは、HMLMアプリ内でユーザー情報をカード形式で表示する「UserCardList」および「UserCard」ウィジェットを定義している。
// // UserCardListは横スクロール形式のカードリストで、複数ユーザーの情報をPageViewで切り替えながら閲覧できる。
// // UserCardは個々のユーザーの「プロフィール画像・名前・自己紹介文」を表示するカードコンポーネント。
// // Firestoreから取得したAppUserデータをUIとして表現し、スワイプ操作で簡単に他ユーザー情報を確認できるデザインとなっている。
// // 主にマップ画面下部などで、近隣ユーザーやおすすめユーザーを紹介する目的で利用される。
