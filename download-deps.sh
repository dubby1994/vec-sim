#!/usr/bin/env bash
# 下载 xlsx 库到 vendor/ 目录
# 使用方法: bash download-deps.sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)/vendor"
mkdir -p "$DIR"
OUT="$DIR/xlsx.full.min.js"

# 候选源（按优先级），任一成功即停止
MIRRORS=(
  "https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"
  "https://unpkg.com/xlsx@0.18.5/dist/xlsx.full.min.js"
  "https://fastly.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"
)

# 期望大小约 900KB+；若文件小于 50KB 视为失败
MIN_SIZE=50000

ok=0
for url in "${MIRRORS[@]}"; do
  echo ">> 尝试: $url"
  if curl -fsSL --connect-timeout 10 --max-time 60 "$url" -o "$OUT"; then
    sz=$(wc -c < "$OUT" | tr -d ' ')
    if [ "$sz" -ge "$MIN_SIZE" ]; then
      echo "✓ 下载成功 ($sz bytes) -> $OUT"
      ok=1
      break
    else
      echo "✗ 文件过小 ($sz bytes)，可能为错误页"
    fi
  fi
done

if [ "$ok" -ne 1 ]; then
  echo ""
  echo "✗ 所有源均下载失败。请手动下载以下任一 URL 到 $OUT"
  for u in "${MIRRORS[@]}"; do echo "   $u"; done
  exit 1
fi

echo "完成。"
