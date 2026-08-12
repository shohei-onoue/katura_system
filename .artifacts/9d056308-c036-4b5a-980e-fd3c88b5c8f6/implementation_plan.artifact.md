# 商品詳細ダイアログの簡素化と数量入力ウィジェットの共通化計画

商品詳細ダイアログから不要な項目を削除してレイアウトを整理するとともに、数量入力機能を共通ウィジェットとして再定義し、プロジェクト全体で一貫した操作性を提供します。

## ユーザーレビューが必要な事項

- **特注数量の連動**: 「特注内容を適用する数量」の初期値は、メインの注文数量と同じにします（例：お弁当10個注文なら、特注数量も初期値10）。
- **共通ダイヤルパッドの名称**: 電話番号入力で使用しているものをベースにした共通ウィジェットを `KNumericDialPad` として定義します。

## 提案される変更

### 1. 共通ウィジェットの作成と整理

#### [NEW] [k_numeric_dial_pad.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_numeric_dial_pad.dart)
- `KPhoneInputPad` をベースに、汎用的な数値入力用ダイヤルパッドを作成します。
- ボタンの大きさや配色を、電話番号入力と数量入力の両方で違和感がないように調整します。

#### [NEW] [k_shared_quantity_input.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_shared_quantity_input.dart)
- 「マイナスボタン」「数量表示（タップでダイヤル表示）」「プラスボタン」をセットにした共通の数量入力ウィジェットを作成します。
- `ItemsSelectionStep` のメニューカードや、詳細ダイアログ内で使用します。

### 2. 商品詳細ダイアログの刷新

#### [MODIFY] [k_item_details_dialog.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_item_details_dialog.dart)
- **項目削除**: ドリンク・サイドメニューの選択リスト、トッピング入力フィールドを廃止します。
- **レイアウト変更**:
    - **上部**: メインの数量入力（`KSharedQuantityInput` を使用）。
    - **中部**: 特注内容入力フィールド。
    - **中部（右）**: 特注内容を適用する数量の入力フィールド。
    - **下部**: お茶の設定（ChoiceChipをより小さく、特典本数入力を統合）。
- **特注数量の実装**: `_specialOrderQuantity` 状態を追加し、メイン数量を超えないようにバリデーションを行います。

### 3. 既存箇所の共通化対応

#### [MODIFY] [items_selection_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/items_selection_step.dart)
- メニューカードの数量操作部分を新設した `KSharedQuantityInput` に置き換えます。

#### [MODIFY] [sidebar_phone_pad.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/sidebar/sidebar_phone_pad.dart)
- 内部で使用している `KPhoneInputPad` を `KNumericDialPad` に置き換えます（または `KPhoneInputPad` 自体を汎用化します）。

## 検証計画

### 自動テスト
- `flutter analyze` で依存関係の整合性を確認します。

### 手動確認
- 詳細ダイアログでドリンク選択が消え、特注フィールドの横に「適用数量」が表示されていることを確認。
- 数量表示をタップした際、サイドバーと同じデザインの入力ダイヤルが表示されることを確認。
- 特注数量がメイン数量と適切に連動（または制限）されていることを確認。
