---
name: debug1000
description: katura_systemをChrome（Web）でデバッグ起動・監視・再起動する。「Chromeでデバッグして」「Webで確認して」等の指示、または /debug1000 で使う。
---

# Chromeデバッグ (katura_system)

katura_systemをChrome上でビルド・起動し、ログを監視して、コード変更後は再起動して反映する手順。

## 1. Chromeの確認

```
flutter devices
```

- `Chrome (web)`（device id `chrome`）が出ていることを確認する。
- 出ていない場合は `flutter config --enable-web` が必要な可能性がある。設定変更になるため、実行前にユーザーの承認を得る。

## 2. 起動

```
flutter run -d chrome
```

- 必ず `run_in_background: true` で実行する（対話的に張り付いたままになるため）。
- 出力ファイルパスを控えておく。

## 3. ログ監視

Monitorツールで出力ファイルを `tail -f` し、以下のシグナルだけ拾う。

```
tail -f -n +1 "<output-path>" \
  | grep -E --line-buffered "Launching|Debug service listening|A Dart VM|Flutter run key commands|Error|FAILED|Exception|Lost connection|Application finished"
```

- 起動成功の合図: `Debug service listening on ...` または `Flutter run key commands.` のログ。これが出たらユーザーにChromeでの起動完了を報告する。

## 4. コード変更後の反映

`flutter run` の対話プロセスへ標準入力でキー送信できないため、**hot reloadは使わずプロセスを再起動**する。

1. 稼働中のMonitorタスクとBash（`flutter run`）タスクをそれぞれ `TaskStop` で停止する。
2. 手順2からやり直す。
3. 手順3の監視を再度張る。
4. 起動完了のログを検知したらユーザーに反映完了を報告する。

## 注意

- Web版では `dart:io` やネイティブ専用プラグインが動かない場合がある。その種のエラーはアプリのWeb非対応部分であり、修正はユーザーに確認してから行う。
- `flutter analyze` は既存の警告が残っていても、新規に増えていなければ問題なしと判断してよい。
