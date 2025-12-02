import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
import 'dart:ui'; // ← ガラス風ぼかしに必要（BackdropFilter）
import 'package:flutter/services.dart'; // クリップボード機能を使用するためのパッケージをインポート
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認証機能を使用するためのパッケージをインポート
import 'package:url_launcher/url_launcher.dart'; // メールアプリなど外部アプリを起動するためのパッケージをインポート

class ContactScreen extends StatefulWidget { // お問い合わせ画面を表すStatefulWidget
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState(); // Stateを生成
}

class _ContactScreenState extends State<ContactScreen> { // お問い合わせ画面の状態管理クラス
  final _formKey = GlobalKey<FormState>(); // フォームのバリデーション管理キー
  final _nameCtrl = TextEditingController(); // 名前入力欄のコントローラ
  final _emailCtrl = TextEditingController(); // メール入力欄のコントローラ
  final _subjectCtrl = TextEditingController(); // 件名入力欄のコントローラ
  final _messageCtrl = TextEditingController(); // お問い合わせ内容入力欄のコントローラ

  // サポート宛先（固定・ユーザー変更不可）
  static const String _supportEmail = 'haruharukiki0918@gmail.com'; // 宛先メールアドレスを固定

  @override
  void initState() { // 画面初期化時の処理
    super.initState();
    final u = FirebaseAuth.instance.currentUser; // 現在ログイン中のユーザー情報を取得
    _nameCtrl.text = u?.displayName ?? ''; // ユーザー名を自動入力（未設定なら空文字）
    _emailCtrl.text = u?.email ?? ''; // ユーザーのメールを自動入力
  }

  @override
  void dispose() { // メモリ解放処理（画面破棄時に呼ばれる）
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async { // メール作成処理
    if (!_formKey.currentState!.validate()) return; // バリデーション未通過なら送信中止

    const to = _supportEmail; // 宛先固定
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown'; // ユーザーID（未ログインならUnknown）
    final subject =
        '[HMLM] お問い合わせ: ${_subjectCtrl.text.trim().isEmpty ? "（件名なし）" : _subjectCtrl.text.trim()}'; // 件名を整形

    final body = ''' // メール本文テンプレートを作成
【お名前】${_nameCtrl.text.trim()}
【ご連絡先メール】${_emailCtrl.text.trim()}
【ユーザーID】$uid
【本文】
${_messageCtrl.text.trim()}
''';

    final uri = Uri( // メール送信用のURIを生成
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication); // メールアプリを起動
      if (!ok) {
        // 失敗時フォールバック：本文をコピーし、手動送信を案内
        await Clipboard.setData(ClipboardData(text: '宛先: $to\n件名: $subject\n\n$body')); // メール内容をクリップボードにコピー
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアプリを開けませんでした。内容をコピーしましたので、手動で貼り付けて送信してください。')), // 手動送信の案内
        );
      }
    } catch (_) { // 例外処理
      await Clipboard.setData(ClipboardData(text: '宛先: $to\n件名: $subject\n\n$body')); // エラー時も内容をコピー
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送信準備でエラーが発生しました。内容をコピーしましたので、手動送信してください。')), // エラーメッセージ表示
      );
    }
  }

  String? _validateRequired(String? v) => // 必須項目のバリデーション
  (v == null || v.trim().isEmpty) ? '必須項目です' : null;

  String? _validateEmail(String? v) { // メール形式のバリデーション
    if (v == null || v.trim().isEmpty) return '必須項目です';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim()); // 正しいメール形式か確認
    return ok ? null : 'メールアドレスの形式が正しくありません';
  }

  @override
  Widget build(BuildContext context) { // UI構築
    return Theme( // テーマカラーをカスタマイズ
        data: Theme.of(context).copyWith(
          colorScheme: Theme
              .of(context)
              .colorScheme
              .copyWith(
            primary: Colors.green[800], // ← 選択時のボーダー色・カーソル色を濃い緑に変更
          ),
        ),
        child: Scaffold(
          appBar: AppBar( // 画面上部のAppBar設定
            title: const Text(
              'お問い合わせ', // タイトル
              style: TextStyle(
                fontWeight: FontWeight.bold, // ← 太字を追加
                color: Colors.black, // 見やすさ維持（明示的に黒指定）
              ),
            ),
            elevation: 4, // 軽いシャドウ
            backgroundColor: const Color(0xFF93B5A5), // ← AppBarの色を #93B5A5 に変更
            surfaceTintColor: Colors.transparent, // Material3のティント無効化
            flexibleSpace: ClipRect( // ぼかし範囲をAppBarに限定
              child: BackdropFilter( // ガラス風ぼかしを適用
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          backgroundColor: Colors.white, // ← 背景色を白に変更
          body: SafeArea( // ノッチやステータスバーを避ける
            child: Center(
              child: ConstrainedBox( // 最大横幅を制限（PCやタブレット対応）
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form( // 入力フォームを定義
                    key: _formKey, // バリデーションキーを設定
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 宛先（固定・非編集）を明示表示
                        TextFormField(
                          initialValue: _supportEmail, // 宛先を表示
                          decoration: const InputDecoration(
                            labelText: '送信先（固定）', // ラベル
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true, // 読み取り専用
                          enabled: false, // 編集無効
                        ),
                        const SizedBox(height: 12),
                        TextFormField( // 名前入力欄
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'お名前',
                            hintText: '例）山田 太郎',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateRequired, // 必須チェック
                        ),
                        const SizedBox(height: 12),
                        TextFormField( // 件名入力欄
                          controller: _subjectCtrl,
                          decoration: const InputDecoration(
                            labelText: '件名（任意）',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: TextFormField( // 問い合わせ本文入力欄
                            controller: _messageCtrl,
                            decoration: const InputDecoration(
                              labelText: 'お問い合わせ内容',
                              hintText: 'できるだけ詳しくご記入ください',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true, // 複数行入力時のラベル位置調整
                            ),
                            maxLines: null, // 行数制限なし
                            expands: true, // 空きスペースを最大限活用
                            validator: _validateRequired, // 必須チェック
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon( // メール送信ボタン
                          onPressed: _send, // 押下時に_send()を実行
                          icon: const Icon(Icons.send, color: Colors.black), // 送信アイコン
                          label: const Text(
                            'メール作成', // ボタンテキスト
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom( // ボタンデザイン設定
                            backgroundColor: const Color(0xFF93B5A5), // テーマカラー
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 角丸
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text( // 注意書きテキスト
                          '端末のメールアプリが起動し、内容が自動入力されます。',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリの「お問い合わせ画面（ContactScreen）」を実装している。
// 主な機能：
// ・ユーザーがアプリ開発者（サポート宛）に問い合わせメールを送るフォーム。
// ・ユーザー名・メールアドレスをFirebaseAuthから自動入力。
// ・入力項目：お名前、件名（任意）、お問い合わせ内容（必須）。
// ・送信時は`mailto:`スキームで端末のメールアプリを自動起動し、件名・本文を自動挿入。
// ・メールアプリが起動できない場合は、内容をクリップボードにコピーし手動送信を案内。
// ・AppBarは#93B5A5色＋ぼかし効果で統一感あるデザイン。
// ・SafeArea＋ConstrainedBoxを使用し、スマホ・タブレット・PCすべてでレイアウトが崩れないよう調整。
// 全体として、ユーザーが安全・簡単にサポートへ連絡できる仕組みを提供している。
