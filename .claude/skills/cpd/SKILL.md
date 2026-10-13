---
name: cpd
description: katura_systemの変更をコミット・プッシュし、Web版をビルドしてFirebase Hostingへデプロイする。「コミットプッシュデプロイして」等の指示、または /cpd で使う。
---

# コミット・プッシュ・デプロイ (katura_system)

## 手順

1. `git status --short` で変更を確認する。変更が無ければ、その旨を伝えて終了する。
2. `flutter analyze lib` を実行し、新規のエラーがあれば中止して報告する（既存の info/warning は無視してよい）。
3. 変更ファイルだけを `git add` する（`git add -A lib` など。`build/` や秘密情報は含めない）。
4. コミットする。メッセージは日本語で変更内容を端的に書き、末尾に会話のsystem-reminderで指定された Co-Authored-By 行を付ける。
5. `git push` する。
6. `flutter build web --release` でWeb版をビルドする。
7. `firebase deploy --only hosting` でデプロイする（公開先: https://katura-system-app.web.app）。
8. コミットID・プッシュ結果・デプロイ結果を3行以内で報告する。

## 注意

- 実機アプリには反映されない（Webのみ）。必要なら `/debug5000` か `/debugwifi` を案内する。
- ブラウザには古い画面が残ることがあるため、反映されない場合はスーパーリロード（Cmd+Shift+R）を案内する。
- 回答はCLAUDE.md 1章に従い、端的に・やさしい言葉で書く。
