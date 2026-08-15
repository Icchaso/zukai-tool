#!/bin/bash
set -e

HTML_FILE="${1:?使い方: deploy-diagram.sh <HTMLファイル> [スラッグ]}"
SLUG="${2:-}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if ! command -v node &>/dev/null; then
    echo -e "${RED}エラー: Node.js がインストールされていません${NC}" >&2
    echo "Node.js をインストールしてから、もう一度試してください。" >&2
    exit 1
fi

if [ ! -f "$HTML_FILE" ]; then
    echo -e "${RED}エラー: $HTML_FILE が見つかりません${NC}" >&2
    echo "先に図解を生成してください。" >&2
    exit 1
fi

# 承認なしで自動公開する運用のため、URLの推測しにくさが唯一の防御になる。
# スラッグだけだと第三者に到達されうるので、必ずランダム6桁を付ける。
RAND=$(openssl rand -hex 3)

if [ -n "$SLUG" ]; then
    DOMAIN="diagram-${SLUG}-${RAND}.surge.sh"
else
    DOMAIN="diagram-$(date +%y%m%d%H%M)-${RAND}.surge.sh"
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

cp "$HTML_FILE" "$TEMP_DIR/index.html"
printf "User-agent: *\nDisallow: /\n" > "$TEMP_DIR/robots.txt"

echo -e "${YELLOW}公開中...${NC}"
npx --yes surge "$TEMP_DIR" --domain "$DOMAIN"

touch deploy-history.log
echo "$(date '+%Y-%m-%d %H:%M:%S') | https://${DOMAIN}" >> deploy-history.log

# デプロイ直後はDNSがまだ伝播しておらず、すぐブラウザで開くと
# ERR_CONNECTION_REFUSED になる。しかもブラウザがその失敗をキャッシュするため、
# あとからアクセスしても「見られない」状態が続く。
# ここで実際に200が返るまで待ってから開くことで、その事故を防ぐ。
echo ""
echo -e "${YELLOW}公開の反映を待っています...${NC}"
if curl -sf --retry 20 --retry-delay 3 --retry-connrefused --max-time 120 \
        -o /dev/null "https://${DOMAIN}/" 2>/dev/null; then
    READY=1
else
    READY=0
fi

echo ""
echo -e "${GREEN}完了！${NC}"
echo "URL: https://${DOMAIN}"

if [ "$READY" -eq 0 ]; then
    echo -e "${YELLOW}※ まだ反映待ちです。1〜2分ほど置いてからアクセスしてください。${NC}"
    echo -e "${YELLOW}  すでに開いて失敗した場合は、ブラウザを Cmd+Shift+R で再読み込みしてください。${NC}"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "https://${DOMAIN}" | pbcopy
    echo -e "${GREEN}URLをクリップボードにコピーしました${NC}"
    if [ "$READY" -eq 1 ]; then open "https://${DOMAIN}"; fi
elif command -v clip.exe &>/dev/null; then
    echo -n "https://${DOMAIN}" | clip.exe
    echo -e "${GREEN}URLをクリップボードにコピーしました${NC}"
    if [ "$READY" -eq 1 ]; then start "https://${DOMAIN}" 2>/dev/null || true; fi
elif command -v xdg-open &>/dev/null; then
    if [ "$READY" -eq 1 ]; then xdg-open "https://${DOMAIN}"; fi
fi

echo -e "${YELLOW}削除するとき: npx surge teardown ${DOMAIN}${NC}"
