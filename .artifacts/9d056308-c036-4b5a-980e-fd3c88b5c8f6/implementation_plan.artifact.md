# 支払いステップのUI詳細化と確認フローの最適化

事前確認（SMS・電話）の運用フローをより具体化し、不要な項目を削除して決済画面を整理します。

## ユーザーレビューが必要な事項

- **SMS設定の仕様**: 歯車アイコンから設定できるのは「送信時間」のみとします。日付は「前日」で固定です。
- **電話連絡の仕様**:
    - 連絡先として「顧客登録番号（この電話番号）」または「指定番号」を選択します。
    - 連絡希望日時（日付＋時間）を設定できるようにします。
- **削除項目**: 「容器回収」スイッチと「受付担当者名」を完全に削除します。

## 提案される変更

### 1. 新しいダイアログ・ウィジェットの作成

#### [NEW] [k_time_selection_dialog.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_time_selection_dialog.dart)
- `KDrumTimePicker` を使用した時間選択専用のダイアログ。SMSの送信時間設定に使用します。

### 2. 支払いステップUIの刷新

#### [MODIFY] [finalize_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/finalize_step.dart)
- **事前確認セクション**:
    - **SMS選択時**:
        - 詳細エリアの青い情報カード内に歯車アイコンを配置。
        - アイコンタップで `KTimeSelectionDialog` を表示。
    - **電話選択時**:
        - アコーディオン形式（展開表示）で「この電話番号」「指定番号へ連絡」の選択ボタンを表示。
        - 「指定番号」時は電話番号入力フィールドを表示。タップで**専用のダイヤルパッドダイアログ**を開くようにします。
        - 連絡希望日時を設定する `KDateTimeDisplay` を追加。
- **項目整理**:
    - 「容器回収」セクションを削除。
    - 「受電担当者（受付担当者）」セクションを削除。

### 3. 受注入力画面の状態管理更新

#### [MODIFY] [order_form_screen.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form_screen.dart)
- 削除した項目（容器回収、受電担当者）の変数を整理。
- 事前確認の新しい詳細情報（電話番号、連絡日時、SMS送信時間）を `FinalizeStep` と同期させます。
- `OrderModel` の保存処理から削除項目を除去。

## 検証計画

### 自動テスト
- `flutter analyze` で不要なプロパティ参照が残っていないか、新規ウィジェットの型エラーがないか確認。

### 手動確認
- SMS選択時にカード内右端の歯車から時間が変更できること。
- 電話選択時にサブメニューが展開され、電話番号と日時が正しく入力・保持されること。
- 画面から「容器回収」と「担当者」が消え、レイアウトが崩れていないこと。
