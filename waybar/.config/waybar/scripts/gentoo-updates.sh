#!/bin/sh

# 修正部分：使用 --only-names 列出名字，再通过 wc -l 计算行数
# 2>/dev/null 用于屏蔽可能的错误信息
counts=$(eix -u --only-names 2>/dev/null | wc -l)

# 再次确保 counts 是纯数字（去掉 wc 可能产生的空格）
counts=$(echo "$counts" | tr -d '[:space:]')

if [ "$counts" -gt 0 ]; then
    # 有更新：显示数量
    # 输出 JSON 格式
    echo "{\"text\": \"$counts\", \"alt\": \"has-updates\", \"class\": \"has-updates\", \"tooltip\": \"$counts packages to update\"}"
else
    # 无更新
    echo "{\"text\": \"\", \"alt\": \"updated\", \"class\": \"updated\", \"tooltip\": \"System is up to date\"}"
fi
