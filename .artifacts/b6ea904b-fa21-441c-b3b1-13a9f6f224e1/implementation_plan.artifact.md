# 画面全体を比率ベースで拡大縮小（プロポーショナル・スケーリング）し、オーバーフローを修正する実装計画

ウィンドウサイズの変更に対し、フォント、余白、コンポーネントのサイズがすべて同じ比率で連動して変化するようにアプリを最適化します。また、`KStepper` で発生しているオーバーフローエラーを解消します。

## ユーザーレビューが必要な項目

> [!IMPORTANT]
> - **スケーリングの完全連動:** 画面幅 1280px を基準（1.0）とし、全てのパディング、マージン、文字サイズをこの係数に乗算します。
> - **オーバーフロー対策:** 文字が長い場合でも `Flexible` と `Ellipsis` を併用し、レイアウトが崩れないようにガードを入れます。
> - **入力パッドのサイズ変更:** テンキーや日本語入力パッドも画面サイズに合わせて大きく・小さくなります。

## 提案される変更

### 1. レスポンシブ・ユーティリティの強化

#### [MODIFY] [k_responsive.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_responsive.dart)
- 「同じ比率」を最優先するため、`scale` の `clamp` 制限を緩和（または撤廃）します。
- 文字が消えないよう、`rf` 関数に最小値（例: 4px）を設定します。

### 2. コンポーネントの比例スケーリング適用

#### [MODIFY] [k_stepper.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_stepper.dart)
- ラベル文字を `Flexible` で包み、オーバーフローを防止します（修正済み）。
- 全ての `SizedBox` や `margin` に `rs` を適用します。

#### [MODIFY] [k_quantity_counter.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_quantity_counter.dart)
- ボタンの大きさ (`60x60`)、文字サイズ、余白を `rs` / `rf` に置き換えます。

#### [MODIFY] [k_phone_input_pad.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_phone_input_pad.dart) / [k_japanese_input_pad.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/widgets/k_japanese_input_pad.dart)
- パッドの横幅 (`380`)、キーの高さ、フォントサイズを全てスケール連動値に変更します。

### 3. サイドバーとチャートの調整

#### [MODIFY] [sidebar_widgets.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/screens/order_form/widgets/sidebar_widgets.dart)
- 統計チャートの高さや棒の太さ、ランキングの文字サイズにスケーリングを適用します。

## Verification Plan

### 自動テスト
- `gradlew :app:assembleDebug` が通ることを確認。

### 手動検証
1. ウィンドウを極端に横に長くしたり、縦に長くしたりして、UI要素が比率を保ったまま追従することを確認。
2. `KStepper` で「配達先の確定」などの長い文字が表示されても、赤いエラー画面が出ないことを確認。
3. 日本語入力パッドなどが、広い画面では押しやすく、狭い画面ではコンパクトに収まることを確認。
