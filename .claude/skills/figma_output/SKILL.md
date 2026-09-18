---
name: figmaout
description: 指定したファイルの内容をFigmaキャンバス上にノードとして生成・出力します
inputs:
  - name: file_path
    description: Figmaへ送信したいファイルのパス
    required: true
  - name: file_key
    description: 出力先となるFigmaファイルのキー（URLの /file/XXXXX/ の部分）
    required: false
---

# Figma Export Skill

以下の手順で指定されたファイルをFigmaに出力してください。

1. **環境変数の確認**
   - 実行前に `FIGMA_ACCESS_TOKEN` が設定されているか確認する。未設定の場合はユーザーに設定を促して中断する。

2. **対象ファイルの解析**
   - `file_path` で指定されたファイルを読み込む。
   - ファイル種別（Flutter Widget、Markdown、JSON、テキスト等）を判別し、Figmaノード（Frame, Text, Rectangle 等）の構造にマッピングする。

3. **Figma APIの実行**
   - 引数で渡された `file_key`（または環境変数 `FIGMA_FILE_KEY`）をターゲットにする。
   - 下記の補助スクリプト（`scripts/figma_exporter.py`）を実行して、Figma REST API経由で要素を描画する。

実行コマンド例:
```bash
python3 scripts/figma_exporter.py --file "$file_path" --target-key "$file_key"

---

**2. API連携スクリプトの作成**

Figma REST APIは読み取りが中心ですが、Canvasへの直接配置やコメント追加、またはプラグイン連携用エンドポイント（Webhook/REST）を叩くためのスクリプト（`scripts/figma_exporter.py`）を配置します。

```python
import os
import sys
import argparse
import requests

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True, help="対象ファイルパス")
    parser.add_argument("--target-key", default=os.getenv("FIGMA_FILE_KEY"), help="Figma File Key")
    args = parser.parse_args()

    token = os.getenv("FIGMA_ACCESS_TOKEN")
    if not token or not args.target_key:
        print("Error: FIGMA_ACCESS_TOKEN または Figma File Key が不足しています。")
        sys.exit(1)

    with open(args.file, "r", encoding="utf-8") as f:
        content = f.read()

    # Figma Plugin (WebSocket / REST Receiver) または Figma REST API への送信処理
    # 例: ファイルレビュー用の新規コメントとして構造をポストする場合
    url = f"https://api.figma.com/v1/files/{args.target_key}/comments"
    headers = {"X-Figma-Token": token, "Content-Type": "application/json"}
    payload = {
        "message": f"Exported from Claude Code ({args.file}):\n\n{content[:500]}...",
        "client_meta": {"x": 0, "y": 0}
    }

    res = requests.post(url, headers=headers, json=payload)
    if res.status_code == 200:
        print("Figma への出力が完了しました。")
    else:
        print(f"送信失敗: {res.status_code} {res.text}")

if __name__ == "__main__":
    main()
