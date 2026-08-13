# 受注区分・お茶設定のUI統合と詳細ダイアログの改善計画

「受注区分」の選択を「配達日時」ステップへ統合し、お弁当とドリンク（サイドメニュー）の同時注文フローを最適化します。また、詳細ダイアログのレイアウトを垂直方向に整頓します。

## ユーザーレビューが必要な事項

- **受注区分の移動**: 「受注区分（直取、結膳など）」は、これまで最終ステップにありましたが、配達方法に関連が深いため「配達日時・受取人」ステップの最初に移動します。
- **グレーアウトの条件**: 配達区分が「引取」の場合、配達を前提とした「結膳」「デリカ」「その他」の受注区分は選択不可（グレーアウト）となります。
- **特注の適用数量**: 特注内容の右隣に、その内容を全注文数のうち何個に適用するかを指定する数量入力フィールドを配置します。

## 提案される変更

### 1. 配達日時ステップへの受注区分統合

#### [MODIFY] [delivery_time_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/delivery_time_step.dart)
- **UI追加**: 「① 配達・引取り区分」のすぐ下に「受注区分」の選択ボタンを追加します。
- **制御ロジック**:
    - `deliveryType == '引取'` の場合、結膳・デリカ・その他のボタンを無効化します。
    - 「その他」選択時は、その右側に詳細入力フィールド（`KMultimodalTextField`）をインラインで表示します。

### 2. 商品詳細ダイアログのレイアウト刷新

#### [MODIFY] [k_item_details_dialog.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_item_details_dialog.dart)
- **垂直整列**:
    - 1. 注文数量
    - 2. 特注内容と適用数量（横並び）
    - 3. お茶の設定と数量（横並び）
    - の順で、上から下へ整然と配置します。
- **数量入力の統一**: すべての数値入力フィールドの幅と右詰め配置を統一します。

### 3. 最終ステップのクリーンアップ

#### [MODIFY] [finalize_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/finalize_step.dart)
- 重複する「受注区分」セクションを削除します。

## 検証計画

### 自動テスト
- `flutter analyze` でプロパティ移動に伴うエラーがないか確認します。

### 手動確認
- 「引取」を選択した際、受注区分の「結膳」などがグレーアウトすることを確認。
- 「詳細設定」ダイアログで、特注内容とその個数が横に並び、下端が揃っていることを確認。
- ダイアログ内の数値入力がすべて右端で垂直に揃っていることを確認。
