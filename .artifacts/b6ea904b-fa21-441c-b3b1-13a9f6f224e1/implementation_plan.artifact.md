# 顧客確認ステップのサイドバー構成変更と「同僚リスト」廃止計画

「顧客確認」ステップ（ステップ 1）の右サイドバーにおける地図表示と同企業他顧客（同僚）リストを廃止し、代わりに売上推移の棒グラフを表示するように変更します。また、不要になった関連コードを削除しクリーンアップします。

## ユーザーレビューが必要な項目

> [!IMPORTANT]
> - **ステップ 1 のサイドバー:** 地図や同僚リストが表示されなくなり、売上推移グラフ（SidebarAnalysis）のみが表示されるようになります。
> - **機能の削除:** 「同企業他顧客リスト」機能はアプリ全体から削除されます。
> - **ステップ 2 以降:** 引き続き、上部に地図、その下にグラフと受注サマリーが表示される構成を維持します。

## 提案される変更

### 1. サイドバー・レイアウトの条件変更

#### [MODIFY] [order_form_sidebar.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/order_form_sidebar.dart)
- 地図の表示条件を `currentStep >= 2` に変更（ステップ 1 では非表示に）。
- ステップ 1 (`currentStep == 1`) の際に `SidebarAnalysis`（グラフ）を単独で表示するようにロジックを修正。
- `SidebarCompanyPeers` の呼び出しを削除。
- 不要になった引数（`companyName`, `companyPeers`, `onShowPin`）を削除。

### 2. 受注入力画面のクリーンアップ

#### [MODIFY] [order_form_screen.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form_screen.dart)
- `_companyPeers` 状態変数を削除。
- `_selectCustomer` 内での同僚リスト取得処理を削除。
- `OrderFormSidebar` 呼び出し時の引数を整理。

### 3. ファイルの削除

#### [DELETE] [sidebar_company_peers.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/sidebar/sidebar_company_peers.dart)
- 使用されなくなる同僚リストのウィジェットファイルを削除します。

## Verification Plan

### 自動テスト
- `gradlew :app:assembleDebug`

### 手動検証
1. 電話番号を入力し、「顧客確認」ステップ（ステップ 1）へ進む。
2. 右サイドバーに**地図が表示されず、棒グラフのみ**が表示されていることを確認。
3. 「配達先の確定」ステップ（ステップ 2）へ進む。
4. 右サイドバーの上部に**地図が復活し、その下にグラフと履歴詳細/サマリー**が表示されることを確認。
5. リファクタリングによる他の機能（顧客検索など）への影響がないことを確認。
