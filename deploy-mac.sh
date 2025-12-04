#!/bin/zsh
set -e

# ======= 配置区：按需修改 =======
BRANCH="master"
VPS_PROJECT_PATH="/opt/firefly/Firefly-blog"
# ===============================

# 提交信息：优先用命令行第一个参数，否则自动生成
if [ -n "$1" ]; then
  COMMIT_MSG="$1"
else
  COMMIT_MSG="chore: update $(date +'%Y-%m-%d %H:%M')"
fi

echo "[local] 当前分支：$BRANCH"
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$BRANCH" ]; then
  echo "[local] ⚠️ 当前不在 $BRANCH 分支，而是在 $current_branch 分支，请先切换分支。"
  exit 1
fi

# 检查是否有改动
if [ -n "$(git status --porcelain)" ]; then
  echo "[local] 检测到未提交改动，准备提交..."
  git add .
  git commit -m "$COMMIT_MSG"
else
  echo "[local] 没有本地改动，跳过 commit。"
fi

echo "[local] 推送到 remote ($BRANCH)..."
git push origin "$BRANCH"

echo "[remote] SSH 到 VPS 执行部署脚本..."
ssh firefly-vps "cd '$VPS_PROJECT_PATH' && ./deploy.sh"

echo "[done] 所有步骤完成，可以刷新 https://blog.eternge.de 查看效果啦 🎉"
