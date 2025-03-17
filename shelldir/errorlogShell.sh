#!/bin/bash

# 로그 파일 경로
ALERT_LOG="/var/log/spring-log.log"
ERROR_LOG_FILE="/var/log/error_detected.log"

# Slack Webhook URL (사용자 맞춤 설정 필요)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

# **현재 시간을 UTC 기준으로 변환**
CURRENT_TIME=$(date -u "+%Y-%m-%d %H:%M:%S")
START_TIME=$(date -u --date="1 minute ago" "+%Y-%m-%d %H:%M:%S")

# **디버깅: 현재 시간과 1분 전 시간 출력**
echo "현재 시스템 시간 (UTC 기준): $CURRENT_TIME"
echo "스크립트에서 계산한 1분 전 시간 (UTC 기준): $START_TIME"

# 최근 1분 동안의 첫 번째 ERROR 로그만 추출 (시간 범위 + 정확한 ERROR 포함)
ERROR_LINE=$(awk -v start="$START_TIME" -v end="$CURRENT_TIME" '
/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/ {
    log_time = substr($0, 1, 19);
    if (log_time >= start && log_time <= end) {
        if ($0 ~ / ERROR /) {
            print $0;
            exit;
        }
    }
}' "$ALERT_LOG")

# ERROR 로그 개수 확인
if [[ -n "$ERROR_LINE" ]]; then
    ERROR_COUNT=1
else
    ERROR_COUNT=0
fi

# **디버깅: 추출된 ERROR 로그 개수와 내용 출력**
echo "스크립트에서 감지한 최근 1분간의 ERROR 로그 개수: $ERROR_COUNT"
echo "스크립트에서 감지한 ERROR 로그 내용:"
echo "$ERROR_LINE"
