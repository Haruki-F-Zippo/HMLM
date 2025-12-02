import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェット群を使うためのパッケージをインポート

class HmlmScreen extends StatelessWidget { // HMLMアプリ内の「HMLMプロフィール画面」を定義するStatelessWidgetクラス
  const HmlmScreen({super.key}); // コンストラクタ。親クラスにkeyを渡すためのsuper.keyを指定

  @override
  Widget build(BuildContext context) { // UIツリーを構築するためのbuildメソッド（毎フレーム呼ばれることがある）
    return Scaffold( // 画面全体の基本レイアウト（AppBar・bodyなど）を提供するウィジェット
      appBar: AppBar( // 画面上部に表示されるAppBar（タイトルバー）を定義
        title: const Text( // AppBarに表示するタイトルテキストを定義
          'HMLM', // タイトル文字列（この画面の名前・アプリ名として表示される）
          style: TextStyle( // タイトルテキストの見た目（フォントスタイル）を指定
            fontWeight: FontWeight.bold, // タイトルを太字にして強調
            color: Colors.black, // タイトル文字の色を黒に設定
          ),
        ),
        backgroundColor: const Color(0xFF93B5A5), // AppBarの背景色をHMLMテーマカラー（#93B5A5）に設定
        elevation: 4, // AppBarの下に影（シャドウ）をつけて立体感を出す
      ),
      backgroundColor: Colors.white, // 画面全体の背景色を白に設定し、テキストを見やすくする
      body: SingleChildScrollView( // 縦方向にスクロール可能なコンテナ。内容が画面より長いときにスクロールできるようにする
        padding: const EdgeInsets.all(16.0), // 画面の四辺に16pxの余白（パディング）をつける
        child: Column( // 子ウィジェットを縦に並べるレイアウトコンテナ
          crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを水平方向に左揃えで配置
          children: [ // Columnの子ウィジェット群をリストで定義
            const Text( // セクションタイトル「HMLMとは」を表示するテキストウィジェット
              'HMLMとは', // ユーザーに見せる見出しテキスト
              style: TextStyle( // 見出しテキストのスタイル指定
                fontSize: 24, // 通常の本文より大きめの文字サイズでタイトル感を出す
                fontWeight: FontWeight.bold, // 太字にして視認性と重要度を強調
              ),
            ),
            const SizedBox(height: 16), // タイトルと最初のプロフィールカードの間に16pxの縦方向スペースを入れる

            const ProfileItem( // 「氏名」情報を1行のカードとして表示するカスタムウィジェット
              title: '氏名', // ラベル部分に表示する文字列
              value: 'HMLM（HateMan LoveMetropolis）', // 内容部分に表示する文字列
            ),
            Row( // 「年齢〜嫌い」のプロフィール群とベルーガ画像を横並びに配置するRow
              crossAxisAlignment: CrossAxisAlignment.start, // Row内の子ウィジェットの上端を揃えて配置
              children: [ // Rowの中に配置する子ウィジェットのリスト
                Column( // 左側に「年齢〜嫌い」のプロフィールカードを縦に並べるColumn
                  crossAxisAlignment: CrossAxisAlignment.start, // 左揃えでカードを並べる
                  children: const [ // Column内に配置するプロフィールカード群
                    ProfileItem( // 「年齢」情報のプロフィールカード
                      title: '年齢', // ラベル文字列
                      value: '10', // 値の文字列
                    ),
                    ProfileItem( // 「出身地」情報のプロフィールカード
                      title: '出身地', // ラベル文字列
                      value: '東京湾', // 値の文字列
                    ),
                    ProfileItem( // 「居住地」情報のプロフィールカード
                      title: '居住地', // ラベル文字列
                      value: '新宿', // 値の文字列
                    ),
                    ProfileItem( // 「好き」情報のプロフィールカード
                      title: '好き', // ラベル文字列
                      value: '都内散歩', // 値の文字列
                    ),
                    ProfileItem( // 「嫌い」情報のプロフィールカード
                      title: '嫌い', // ラベル文字列
                      value: '人間', // 値の文字列
                    ),
                  ],
                ),
                const SizedBox(width: 1), // プロフィールカード群と画像の間に10pxの横スペースを入れる
                Padding( // 画像全体の表示位置に上下左右の余白を加えるためのラッパーウィジェット
                  padding: const EdgeInsets.only(top: 30), // 上方向に16pxの余白を追加して画像を少し下に配置する
                  child: SizedBox( // 右側に表示するベルーガ画像の枠を定義するコンテナ
                    width: 210, // 画像表示領域の横幅
                    height: 240, // 画像表示領域の高さ
                    child: Image.asset( // アセットから画像を読み込んで表示するウィジェット
                      'assets/images/HMLM_Beluga_Front.png', // 表示するベルーガ画像ファイルのパス
                      fit: BoxFit.contain, // 枠内に収まるように縦横比を保ちながら表示
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2), // 基本プロフィール群（＋画像）と長文セクションの間に20pxのスペースを入れる

            const ProfileLongItem( // 本人紹介（長めの文章）をカード形式で表示するカスタムウィジェット
              title: '本人紹介', // セクションのタイトル文字列
              value: '都内付近の利便性という甘い蜜を啜り続けたいという気持ちで新宿に住み始めたが、想像を絶する大量の人間の群れに怯え、震えて自宅から出られない。 \n外出するためにも嫌いな人間が少なく魅力的な近場を顔も知らない隠キャの仲間たち（HMLMアプリユーザーのこと）に応援を求めHMLMアプリを開発。', // 本人紹介の本文テキスト
            ),

            const SizedBox(height: 20), // 本人紹介セクションと「夢」セクションの間に20pxのスペースを入れる

            const ProfileLongItem( // 夢（長めの文章）をカード形式で表示するカスタムウィジェット
              title: '夢', // セクションタイトル文字列
              value: 'このアプリを通じて、人混みが苦手で今も外に出られない都内在住の仲間の隠キャ達（HMLMアプリユーザーのこと）を外の世界を連れ出したい。', // 夢の本文テキスト
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget { // 短文プロフィール項目（氏名・年齢など）1行分を表示するためのカスタムウィジェット定義
  final String title; // 左側のラベル（項目名）を保持するフィールド
  final String value; // 右側の値（項目内容）を保持するフィールド

  const ProfileItem({super.key, required this.title, required this.value}); // コンストラクタ。titleとvalueの指定を必須にする

  @override
  Widget build(BuildContext context) { // このウィジェットの具体的な見た目を構築するbuildメソッド
    return Container( // 1つのプロフィール行全体を包むコンテナ（背景・余白・角丸などを設定）
      margin: const EdgeInsets.only(bottom: 12), // このカードの下側にだけ12pxの余白を入れ、カード同士を離す
      padding: const EdgeInsets.all(14), // コンテナ内部に全方向14pxのパディングを入れて内容に余裕を持たせる
      decoration: BoxDecoration( // コンテナの装飾（背景色や角丸）を定義するクラス
        color: const Color(0x3393B5A5), // HMLMテーマカラーを20%程度の透明度で薄く敷いた背景色
        borderRadius: BorderRadius.circular(12), // コンテナの四隅を12pxの半径で丸くする
      ),
      child: Row( // ラベルと値を左右に並べるためのRowレイアウト
        mainAxisSize: MainAxisSize.min, // Rowの幅を「必要最小限の幅」にする（中身に合わせてカードをコンパクトにする）
        children: [ // Row内に横並びで配置する子ウィジェットたち
          Text( // 左側に表示するラベルテキスト（氏名・年齢など）
            '$title：', // ラベル文字列の後ろにコロン（：）を付けて項目名っぽく見せる
            style: const TextStyle( // ラベルテキストのスタイル指定
              fontWeight: FontWeight.bold, // 太字にしてラベルとしての重要度を強調
              fontSize: 16, // 読みやすい標準的な文字サイズ
            ),
          ),
          const SizedBox(width: 8), // ラベルと値の間に8pxの横方向スペースを空ける
          Text( // 右側に表示する値テキスト（中身の情報）
            value, // 実際に表示する値の文字列（例：10、新宿 など）
            style: const TextStyle( // 値テキストのスタイル指定
              fontSize: 16, // ラベルと同程度の読みやすい文字サイズ
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLongItem extends StatelessWidget { // 本人紹介・夢などの長文のプロフィール項目を表示するカスタムウィジェット定義
  final String title; // セクションのタイトル（見出し）を保持するフィールド
  final String value; // セクションの本文テキストを保持するフィールド

  const ProfileLongItem({super.key, required this.title, required this.value}); // コンストラクタ。titleとvalueの指定を必須にする

  @override
  Widget build(BuildContext context) { // このウィジェットの見た目を構築するbuildメソッド
    return Container( // 長文セクション全体を包むコンテナ（背景・パディング・角丸などを設定）
      padding: const EdgeInsets.all(16), // コンテナ内部に16pxのパディングを入れて文章を読みやすくする
      decoration: BoxDecoration( // コンテナの装飾（背景色や角丸）を定義
        color: const Color(0x2293B5A5), // さらに薄めたHMLMテーマカラーの背景色（約13%透明度）
        borderRadius: BorderRadius.circular(12), // コンテナの四隅を12pxの半径で丸くする
      ),
      child: Column( // タイトルと本文を上下に並べるための縦方向レイアウト
        crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えで配置
        children: [ // Column内に縦並びで配置するウィジェットのリスト
          Text( // セクションタイトル（本人紹介・夢など）を表示するテキスト
            '$title：', // タイトル文字列の後ろにコロン（：）を付けてセクション見出しとして表示
            style: const TextStyle( // セクションタイトルのスタイル指定
              fontWeight: FontWeight.bold, // 太字にして強調
              fontSize: 18, // 通常本文よりやや大きい文字サイズで見出し感を出す
            ),
          ),
          const SizedBox(height: 8), // タイトルと本文テキストの間に8pxの縦方向スペースを空ける
          Text( // セクションの本文テキストを表示するウィジェット
            value, // 実際に表示する長文の内容
            style: const TextStyle( // 本文テキストのスタイル指定
              fontSize: 16, // 読みやすい標準的な文字サイズ
              height: 1.4, // 行間を1.4倍にして詰まりすぎないようにする
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体が何をしているか
// =============================
// ・このファイルは、HMLMアプリ内の「HmlmScreen」というプロフィール画面を定義している。
// ・Scaffoldを使い、AppBarとbodyを持つ1つの画面として構成されている。
// ・AppBar：タイトル「HMLM」、テーマカラー #93B5A5、影付きでアプリのブランド感を表現。
// ・body：SingleChildScrollView内にColumnでウィジェットを縦並びにし、
//   - Text「HMLMとは」 …… 画面のセクションタイトル。
//   - ProfileItem …… 氏名／年齢／出身地／居住地／好き／嫌い の短いプロフィール項目を
//                       薄いテーマカラー背景＋角丸のカードとして表示。
//   - Row（年齢〜嫌い ＋ 画像） …… 左にプロフィールカード群、右にベルーガ画像
//                       （HMLM_Beluga_Front.png）を配置し、画面右側の空白を有効活用。
//   - ProfileLongItem …… 本人紹介／夢 といった長文テキストを読みやすいカードで表示。
// ・全体として、HMLMというキャラクターのプロフィールと世界観を、
//   テキスト＋カードレイアウト＋キャラクター画像でユーザーに伝える画面となっている。
