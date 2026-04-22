# calcure — 子ども向け計算練習アプリ

## プロジェクト概要

- **アプリ名**: けいさんれんしゅう
- **Bundle ID**: `jp.kujirabo.calcure`
- **対象**: 子ども向け四則演算ドリル
- **フレームワーク**: Flutter（対象プラットフォーム: macOS / iOS / Android / Web）
- **コピーライト**: © 2026 kujirabo.jp yamamotodin

---

## ファイル構成

```
.github/
└── workflows/
    └── deploy.yml               # GitHub Actions デプロイワークフロー
lib/
├── main.dart                    # エントリポイント
├── models/
│   ├── quiz_settings.dart       # 設定モデル（演算・桁数・制限時間）
│   ├── quiz_problem.dart        # 問題生成ロジック
│   ├── problem_result.dart      # 1問ごとの結果モデル
│   └── session_result.dart      # 1セッション分の結果モデル（JSON対応）
├── services/
│   └── session_store.dart       # shared_preferences によるセッション永続化
└── screens/
    ├── home_screen.dart         # 設定画面（トップ）
    ├── quiz_screen.dart         # クイズ画面
    ├── result_screen.dart       # 結果画面
    ├── history_screen.dart      # 1セッション内の問題別結果画面
    └── session_list_screen.dart # セッション一覧画面
```

---

## 画面フロー

```
HomeScreen
  ├── [スタート！] → QuizScreen
  │                     └── [終了] → ResultScreen
  │                                     ├── [といあわせ けっかをみる] → HistoryScreen
  │                                     ├── [もういちど] → QuizScreen（同設定）
  │                                     └── [せってい にもどる] → HomeScreen
  └── [履歴アイコン] → SessionListScreen
                           └── [セッションタップ] → HistoryScreen
```

---

## 設定項目（HomeScreen）

| 項目 | 選択肢 | デフォルト |
|------|--------|-----------|
| けいさんのしゅるい | ＋ / － / × / ÷（複数選択可・最低1つ必須） | ＋ |
| けたすう | 1桁（1〜9）/ 2桁（10〜99）/ 3桁（100〜999） | 1桁 |
| せいげんじかん | 30秒 / 1分 / 2分 / なし | 1分 |

- ホーム画面右上の履歴アイコンでセッション一覧へ遷移
- ホーム画面下部にコピーライト表示

---

## クイズ仕様（QuizScreen）

### 問題生成ルール（`quiz_problem.dart`）

| 演算 | 生成ルール |
|------|-----------|
| 足し算 | 左辺・右辺ともに桁数範囲からランダム |
| 引き算 | 左辺≧右辺になるよう入れ替え（答えが0以上） |
| 掛け算 | 左辺は桁数範囲、右辺は1〜9固定（答えが膨大にならないよう） |
| 割り算 | 割り切れる問題のみ。除数1〜9、商は桁数上限から逆算して生成 |

### 入力方式

数字ボタン **0〜9**（電話キーパッドレイアウト）

```
[1] [2] [3]
[4] [5] [6]
[7] [8] [9]
[⌫] [0] [こたえる]
```

- `⌫`：1文字削除
- `こたえる`：回答確定（入力が空の場合は無効・グレーアウト）
- すべてのボタンは同じサイズ（`Material` + `InkWell` で統一）

### 終了条件

| モード | 終了条件 |
|--------|---------|
| 制限時間あり | タイマーが0になった時点で結果画面へ |
| 制限時間なし | 10問回答で結果画面へ（定数 `_kQuestionsWithoutTimer = 10`） |

### フィードバック

- 回答後 700ms 間、入力欄の色と✓/✗アイコンで正誤を表示
- 正解：緑 / 不正解：赤

---

## 結果画面（ResultScreen）

- クイズ終了時に **自動でセッションを `SessionStore` へ保存**
- 表示: もんだいすう・せいかい・まちがい・せいかいりつ
- 正解率に応じた絵文字とメッセージ

| 正解率 | 絵文字 | メッセージ |
|--------|--------|-----------|
| 90%以上 | 🎉 | すごい！ |
| 70%以上 | 😊 | よくできました！ |
| 50%以上 | 🤔 | もうすこし！ |
| 50%未満 | 😅 | がんばろう！ |

---

## 履歴・セッション管理

### HistoryScreen（1セッションの問題別結果）

- 問題ごとにカード表示
- 正解の場合: 問題文 ＋ ユーザーの答え ＋ ✓
- 不正解の場合: 問題文 ＋ ユーザーの答え → 正解 ＋ ✗
- AppBar タイトルは呼び出し元から渡せる（`title` パラメータ、デフォルト: `'といあわせ けっか'`）

### SessionListScreen（セッション一覧）

- `SessionStore.loadAll()` で新しい順に一覧表示
- 各セッションカードに表示: 日時・設定チップ（演算/桁数/制限時間）・正解数・正解率
- タップで `HistoryScreen` へ遷移
- 右上のゴミ箱アイコンで全セッション削除（確認ダイアログあり）

### SessionStore（永続化）

- `shared_preferences` パッケージを使用
- キー: `session_results`（JSON 文字列のリストとして保存）
- `SessionResult` は `toJsonString()` / `fromJsonString()` で直列化
- プラットフォーム別の保存先:
  - macOS: `UserDefaults`
  - Web: ブラウザの `localStorage`
  - Android: `SharedPreferences`
  - iOS: `NSUserDefaults`

---

## 依存パッケージ

| パッケージ | 用途 |
|-----------|------|
| `cupertino_icons` | iOS スタイルアイコン |
| `shared_preferences ^2.3.0` | セッション結果の永続化 |

---

## デザイン方針

- 子ども向けのため **ひらがな** を基本とした UI テキスト
- 画面ごとにテーマカラーを統一

| 画面 | 背景色 | アクセントカラー |
|------|--------|----------------|
| ホーム | `#FFF8E1` | `#E65100`（オレンジ） |
| クイズ | `#E3F2FD` | `#1565C0`（ブルー） |
| 結果・履歴 | `#F3E5F5` | `#6A1B9A`（パープル） |

- ボタンは大きめ（子どもがタップしやすい）
- アニメーション: 正誤フィードバックに `AnimatedContainer` を使用

---

## デプロイ（GitHub Actions）

### ワークフロー: `.github/workflows/deploy.yml`

- **トリガー**: `main` ブランチへのプッシュ
- **認証**: OIDC（IAMロール）で AWS 認証（アクセスキー不要）
- **Flutterバージョン**: stable チャンネルの最新版

### 必要な GitHub Secrets

| Secret名 | 内容 |
|----------|------|
| `AWS_ROLE_ARN` | OIDC で assume する IAM ロールの ARN |
| `AWS_REGION` | AWS リージョン（例: `ap-northeast-1`） |
| `AWS_S3_BUCKET_NAME` | S3 バケット名 |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | CloudFront ディストリビューション ID |

### デプロイ先

- S3パス: `s3://BUCKET_NAME/calcure/`
- CloudFront キャッシュ無効化パス: `/calcure/*`

### キャッシュ戦略

| ファイル | Cache-Control |
|---------|---------------|
| `index.html` / `flutter_service_worker.js` | `no-cache, no-store, must-revalidate` |
| その他のアセット（JS・CSS・画像） | `public, max-age=31536000, immutable`（1年） |

### CloudFront エラーページ設定（必須・コンソールで設定）

Flutter Web は SPA のため、以下のカスタムエラーレスポンスが必要:

| エラーコード | レスポンスページ | HTTP ステータス |
|------------|----------------|---------------|
| 403 | `/index.html` | 200 |
| 404 | `/index.html` | 200 |

### IAM ロールに必要な権限

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::YOUR_BUCKET_NAME",
        "arn:aws:s3:::YOUR_BUCKET_NAME/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::YOUR_ACCOUNT_ID:distribution/YOUR_DISTRIBUTION_ID"
    }
  ]
}
```
