#!/bin/bash
# 極簡版 MCP 提供者啟動腳本

# 切換到腳本所在目錄
cd "$(dirname "$0")" > /dev/null 2>&1

# 直接構建應用程序（可選，如果應用已構建可注釋此行）
swift build -q -c release > /dev/null 2>&1

# 直接啟動應用程序
.build/release/__PROJECT_NAME__

# 返回應用程序的退出代碼
exit $?