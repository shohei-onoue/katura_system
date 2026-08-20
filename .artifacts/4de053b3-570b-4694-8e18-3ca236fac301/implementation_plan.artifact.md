# SNS（SMS）実送信機能の実装

端末のメッセージアプリを起動し、事前に入力された宛先と本文をセットした状態でSMSを送信できる機能を実装します。

## 変更内容の概要

1. **ライブラリの導入**: `url_launcher` パッケージをプロジェクトに追加します。
2. **OS設定の追加 (Android)**: Android 11以降で外部アプリ（メッセージアプリ）を起動するために必要な `queries` 設定を `AndroidManifest.xml` に追加します。
3. **送信ロジックの更新**: 「テスト送信」ボタンの動作を、シミュレーションから「メッセージアプリの起動」に切り替えます。
    - 送信先: 画面に表示されている「受電番号」
    - 本文: 「【かつら】ご注文ありがとうございます。前日 XX:XX 頃に最終確認のご連絡を差し上げます。」

## Proposed Changes

### [Component Name] root

#### [MODIFY] [pubspec.yaml](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/pubspec.yaml)
- `dependencies` に `url_launcher: ^6.3.0` を追加。

### [Component Name] android

#### [MODIFY] [AndroidManifest.xml](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/android/app/src/main/AndroidManifest.xml)
- `<queries>` セクション内に `<intent><action android:name="android.intent.action.VIEW" /><data android:scheme="sms" /></intent>` を追加。

### [Component Name] screens/order_form

#### [MODIFY] [finalize_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/finalize_step.dart)
- `url_launcher` をインポート。
- `_simulateSending` を削除し、実送信用のメソッド `_sendActualSms` を実装。
- `_handleTestSnsSend` 内の「送信する」ボタン押下時に、実送信メソッドを呼び出すように変更。

## Verification Plan

### Automated Tests
- `flutter pub get` が正常に完了すること。
- ビルドが正常に通ること。

### Manual Verification
1. 実機（またはSMS対応のエミュレータ）でアプリを起動。
2. 注文フローを進め、Step 6 「支払・完了」を表示。
3. 「SNS送信」を選択し、「テスト送信」をタップ。
4. ダイアログで「送信する」をタップ。
5. **期待される動作**: 端末の標準メッセージアプリが開き、宛先に番号、本文に定型文が入っていることを確認。
