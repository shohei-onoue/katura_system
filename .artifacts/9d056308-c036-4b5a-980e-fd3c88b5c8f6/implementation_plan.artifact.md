# 配達日時ステップのUI刷新計画（ダイアログ式日時設定）

配達日時ステップの操作性を向上させるため、日付と時間の選択をダイアログ形式に統合し、メイン画面のレイアウトを整理します。

## ユーザーレビューが必要な事項

- **セクションの統合**: 「配達・引取り区分」の選択ボタンの横に日付と時間の表示フィールドを配置するため、従来の「日時の決定」セクションは統合・削除されます。
- **ダイアログの構成**: ダイアログの上部にカレンダー（TableCalendar）、下部に時間（ドラム式ピッカー）を表示し、一画面で両方を設定できる構成にします。
- **ゴミ回収セクションの扱い**: 今回の指示は「配達引取り選択ボタンの右側」についてですが、UIの統一性のため、ゴミ回収の日時設定も同様の表示フィールド＋ダイアログ形式に変更することを提案します。（一旦、指示通りメインの配達セクションから適用します）

## 提案される変更

### [Component Name] Widgets & Screens

#### [NEW] [k_date_time_selection_dialog.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_date_time_selection_dialog.dart)
`TableCalendar` と `CupertinoPicker`（ドラム式）を組み合わせた日時選択専用ダイアログを作成します。

#### [MODIFY] [delivery_time_step.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/steps/delivery_time_step.dart)
- セクション1のタイトルを「１．配達・引取り区分」に変更します。
- `KChoiceGroup` の右側に日付・時間の表示フィールドを配置します。
- フィールドタップ時に `KDateTimeSelectionDialog` を表示するようにします。
- 旧「２．日時の決定」セクションを削除し、後続のセクション番号を振り直します。

## 検証計画

### 自動テスト
- ビルドが正常に通ることを確認します。

### 手動確認
- 「配達・引取り区分」セクションで、日付・時間フィールドをタップするとダイアログが開くこと。
- ダイアログで日付（カレンダー）と時間（ドラム）を選択し、「反映」ボタンで元の画面に正しく反映されること。
- 配達・引取りの切り替えが正しく動作すること。
