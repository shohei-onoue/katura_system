# SMS確認 設計案（顧客が確認リンクを開く → 確認済み / 未確認 → 電話確認へ）

調査日: 2026-10-02 / 調査のみ。コードは一切変更していません。

用語メモ
- SMS: 携帯電話に届く短い文字メッセージ。
- Cloud Functions: Googleのサーバーで、プログラムを自動で動かす仕組み。
- Firestore: 注文などを保存しているGoogleのデータ置き場（データベース）。
- Hosting: 小さなWebページをインターネットに公開する場所。
- トークン: 本人だけが知っている長いランダムな文字列（合言葉のようなもの）。

---

## (1) 現状

### SMSを送っている場所
| 場所 | 何をしている |
|---|---|
| `functions/index.js` の `orderAutoSms` | 毎分動き、設定した時刻(例 09:00)に「明日配達」かつ事前連絡が「SMS」かつ未送信の注文へ、Vonage(SMS会社)経由で確認文を送る。送れたら `smsSent=true` と `smsSentAt` を書く。 |
| `lib/services/sms_service.dart` | 事前連絡が「電話」のとき、担当者向けリマインドSMSを `sms_outbox`(送信待ち箱)に入れる。 |
| `lib/screens/order_form_screen.dart` (約1450-1485行) | 上記を呼ぶ。担当者番号は設定画面(`settings/sms_config`)から取得。 |
| `lib/screens/settings_screen.dart` | 送信時刻と担当者番号の設定。 |
| `functions/src/index.ts.bak` | 古い版のバックアップ(使われていない)。 |

### 使っているFirebase
- `pubspec.yaml`: firebase_core, cloud_firestore, firebase_storage, firebase_auth, http, url_launcher。
- `firebase.json`: Flutterの設定と `functions` のみ。**Hosting(Web公開)の設定はない**。
- `functions/` フォルダ: あり(Node 20、firebase-functions v4、axios)。送信は `orderAutoSms` の1つだけ。
- データベース名は `katura-system-database`(標準でない名前)。Firestoreのルールファイル(firestore.rules)はリポジトリに無い。
- `web/` フォルダ: あり(Flutter Web用)。

### 注文データの現状
`lib/models/order_model.dart` に以下がある。
- `preConfirmationMethod`(SMS/電話)、`preConfirmationSmsTime`、`scheduledSmsDateTime`、`smsSent`(送信済みか)
- `status`(受注済みなど注文全体の状態)
- 「顧客が読んだか」「電話連絡がついたか」を持つ項目は**まだ無い**。

### 現状の問題点
- 現在のSMS本文は「内容を送るだけ」。お客様が見たかどうかを店が知る方法が無い。
- `sms_outbox` を読んで実際に送る処理は `functions/index.js` に**見当たらない**(要確認。担当者向けリマインドが実際に届いているか未確認)。
- Vonageの `api_key` / `api_secret` が `index.js` にそのまま書かれている(下の懸念点参照)。

---

## (2) 提案する仕組み(流れ)

1. 注文が「明日配達・SMS」になると、いつも通り `orderAutoSms` が確認SMSを送る。
2. その前に、注文ごとに**推測できない合言葉(トークン)**を作り、本文に確認リンクを入れる。
   例: `https://(公開URL)/c/ランダム文字列`
3. お客様がリンクを開くと、確認ページ(注文内容の表示 + 「確認しました」ボタン)が開く。
   - 開いた時点で「開封済み(`openedAt`)」を記録。
   - ボタンを押したら「確認済み(`confirmedAt`)」を記録。
4. 店側アプリで注文の連絡状況を表示する(未送信 / 送信済み / 開封 / 確認済み / 未確認)。
5. 期限(例: 配達前日の15:00。店で決める)になっても未確認なら、自動で「電話確認が必要」に変え、担当者へ知らせる(既存のリマインドSMSの仕組みを再利用)。
6. 担当者が電話し、結果(連絡つながった / 不在 / 変更あり)を記録。電話で確認できたら「確認済み(電話)」にする。

### 注文データに足す項目(案)
注文ドキュメント(`orders`)に次をまとめて持たせる。別コレクションにしない理由は、注文一覧で一緒に読めて簡単だから。

```
confirmation: {
  token: "ランダム文字列",        // リンク用の合言葉
  tokenExpiresAt: 日時,           // 期限(配達日まで)
  state: "none|sent|opened|confirmed|needs_call|call_done|call_failed",
  sentAt, openedAt, confirmedAt,  // 日時
  confirmedBy: "link" | "phone",  // どうやって確認したか
  callNote: "電話メモ",
  callAt: 日時
}
```
- 既存の `smsSent` は残し、互換性を保つ(古い注文はそのまま動く)。
- リンク用に別コレクション `confirm_tokens/{token}` を作り、注文IDだけ入れる方法もある。こちらの方が注文の個人情報を直接読ませずに済み安全(推奨)。

---

## (3) 必要な変更ファイルと新規追加物

### 変更するファイル
| ファイル | 内容 |
|---|---|
| `lib/models/order_model.dart` | 連絡状況の項目を追加(toMap/fromMapも)。 |
| `functions/index.js` | SMS本文に確認リンクを入れる。トークン作成。未確認を検知して `needs_call` にする定期処理を追加。 |
| `lib/services/order_service.dart` など | 電話確認の結果を保存する関数。 |
| `lib/services/sms_service.dart` | 未確認時の担当者リマインド送信(既存を再利用)。 |
| `firebase.json` | Hosting(確認ページの公開)の設定を追加。 |

### 新規追加物(**すべて承認が必要**)
| 追加物 | 理由 | 承認 |
|---|---|---|
| Firebase Hosting の有効化と確認ページ(`web`内または別の小さなHTML) | お客様が開く公開ページが必要。今は無い。 | 必要 |
| Cloud Functions の追加(確認ページ用の関数 `confirmOrder` と、未確認検知の定期関数) | ページから安全に注文を更新するため。お客様に直接Firestoreを触らせない。 | 必要(デプロイ=公開作業も承認が必要) |
| Firestoreルールの追加(`firestore.rules`) | お客様が注文を読み書きできないように守る。 | 必要 |
| 新しいFlutterパッケージ | **基本的に不要**(`url_launcher` で電話発信可能、既存で足りる)。 | 不要の見込み |
| Cloud Scheduler | 既存の `onSchedule` が自動で使うので追加不要の見込み。 | 要確認 |
| 短縮URL(SMSは文字数に制限があるため) | リンクを短くしたい場合のみ。独自の短いドメインまたは短縮サービス。 | 必要(任意) |

---

## (4) UI変更が必要な箇所(**要承認**。CLAUDE.md 2章により、承認前は変更しません)

1. お客様用の確認ページ(新規画面。見た目の設計が必要)。
2. 注文詳細 / 受注一覧 / 配達予定ダイアログに「連絡状況」のバッジ表示(送信済み・確認済み・未確認など)。
3. 「電話確認が必要」の一覧または通知、電話ボタンと結果入力(つながった/不在/変更あり + メモ)。
4. 設定画面に「未確認とみなす期限」の項目追加。
5. (任意) `customer_confirmation_step.dart` 周辺の文言調整。

---

## (5) 懸念点

- **秘密情報の流出(最重要)**: Vonageの `api_key` と `api_secret` が `functions/index.js` と `index.ts.bak` に書き込まれたまま。Gitに入っていれば漏れている可能性があるため、キーの再発行と、Functionsの「シークレット機能」(秘密の金庫)への移動を推奨。
- **リンクの安全性**: トークンは推測できない長さにし、期限を付ける。個人情報(住所・電話)はページに出し過ぎない。
- **SMSの文字数/料金**: 日本語は短くても複数通に分かれ料金が増える。リンクが長いと不利。
- **開いただけでは「確認済み」にしない**: 迷惑メール対策ソフトやスマホの先読みが自動でリンクを開くことがある。そのため「開封」と「確認ボタン押下」を分ける設計にしている。
- **電話番号が固定電話の場合**: SMSが届かない。その場合は最初から電話確認へ回す必要がある。
- **`sms_outbox` の送信処理が見当たらない**: 担当者リマインドが実際に送られているか要確認。
- **同時実行/二重送信**: `orderAutoSms` は毎分動く。送信失敗時の再送ルール(何回まで)を決める必要がある。
- **Firestoreルール**: リポジトリに無く、現状の保護が不明。公開ページを作る前に確認が必要。
- **確認期限や電話に切り替える時刻**: 店のルール(前日何時まで?)をヒアリングで決める必要がある。
- **デプロイは承認必須**: Functions/Hostingの公開は本番に影響するため、実施前に必ず承認を取る。
