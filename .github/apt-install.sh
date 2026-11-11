#!/usr/bin/env bash
# 安装 CI 需要的系统包。Ubuntu 软件源偶尔卡住不返回，apt 默认不超时，会一直等到任务超时（1 小时）。
# 这里给每次请求加超时与重试，整次 update / install 也限时，失败后换一轮重来。
set -uo pipefail
opts=(-o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o DPkg::Lock::Timeout=60)
for attempt in 1 2 3; do
  if timeout 300 sudo apt-get "${opts[@]}" update &&
    timeout 600 sudo DEBIAN_FRONTEND=noninteractive apt-get "${opts[@]}" install -y "$@"; then
    exit 0
  fi
  echo "::warning::安装系统包失败（第 $attempt 次），稍后重试"
  sleep 20
done
echo "::error::安装系统包失败：$*"
exit 1
