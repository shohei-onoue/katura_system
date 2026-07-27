# Google Maps API 診断機能の強化とエラー解消計画

タブレットシミュレータおよびWeb環境で検索結果が出ない問題を解決するため、APIからの詳細なエラー応答を可視化し、原因を特定・解消します。

## ユーザーレビューが必要な項目
> [!IMPORTANT]
> **Google Cloud Console での確認事項:**
> 1. **キーの制限:** 「リファラー制限」がかかっているとAndroid/iOSでは動作しません。一時的に「制限なし」にしてテストしてください。
> 2. **有効なAPI:** **Places API (Newではない方)** が有効になっているか確認してください。
> 3. **請求設定:** クレジットカードが登録されており、プロジェクトに紐付いているか確認してください（必須です）。

## 提案される変更

### [Component] GoogleMaps サービス (Diagnostics)

#### [MODIFY] [google_maps_service.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/google_maps_service.dart)
- `searchPlacesByText` において、`status != 'OK'` の場合に Google から返される `error_message` を抽出し、`debugPrint` で出力するように強化します。

### [Component] 受注画面ロジック (Error Handling)

#### [MODIFY] [order_form_screen.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form_screen.dart)
- APIエラー発生時に、デバッグ時のみ詳細なステータスコードを SnackBar またはログに表示するようにし、現場での切り分けを可能にします。

## Verification Plan

### 自動テスト
- `gradlew :app:assembleDebug`

### 手動検証（シミュレータ）
1. 施設検索を実行。
2. Android Studio の **Logcat** を開き、`Google Maps Text Search Status:` と `Error Details:` の出力を確認。
3. `REQUEST_DENIED` の理由（API key not authorized, Billing not enabled 等）を確認。
