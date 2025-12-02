import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使うためのFlutterパッケージをインポート

class AuthModalImage extends StatelessWidget { // 認証モーダル画面に表示する画像ウィジェットを定義するStatelessWidgetクラス
  const AuthModalImage({super.key}); // コンストラクタ（キー指定のみで初期化）

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return SizedBox.square( // 幅と高さが等しい正方形サイズのウィジェットを作成
      dimension: 300, // 正方形の一辺の長さを300ピクセルに設定（レイアウト側から指定される“表示枠”）
      // child には、画像の「上 80% だけを表示する」仕組みを追加する
      child: ClipRect( // ← 子ウィジェットの描画領域を切り取る（トリミング）ためのウィジェット
        child: Align(
          alignment: Alignment.topCenter, // ← 画像の“上側”を基準にして表示する（上を残して下を削る）
          heightFactor: 0.8, // ← ★ 縦方向の 80% だけを表示（= 下 20% を切り捨て）
          child: Image.asset(
            'assets/images/HMLM_Beluga_Standard.png', // アセット内の画像「HMLM_Beluga_Standard.png」を読み込んで表示
            fit: BoxFit.cover, // ← 表示枠いっぱいにフィットするように画像を拡大・縮小
          ),
        ),
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明（変更後）
// =============================
// ・このファイルは、HMLMアプリ内の認証モーダル（ログイン・新規登録画面など）で表示される画像を定義している。
// ・「AuthModalImage」ウィジェットは、assetsフォルダ内の「HMLM_Beluga_Standard.png」を
//   300×300サイズの正方形枠の中に表示する。
// ・以前は画像全体（縦100%）を表示していたが、現在は ClipRect + Align を使い、
//   「画像の上側 80% だけを表示し、下側 20% をカット」するようにしている。
//   - Align の alignment: Alignment.topCenter により、表示基準を“画像の上端”に固定。
//   - heightFactor: 0.8 によって、縦方向の 80% 部分のみを表示（= 下 20% がトリミングされる）。
// ・画像そのもののファイル（PNG）は加工せず、UI側のレイアウトだけでトリミングを実現しているため、
//   将来的に同じ画像を他の場所ではフルサイズで使うことも可能。
// ・SignInForm などからは従来どおり AuthModalImage() を呼び出すだけで、
//   自動的に“下 20% を切り取った状態”のベルーガ画像が表示される。
