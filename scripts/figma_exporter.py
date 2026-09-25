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
