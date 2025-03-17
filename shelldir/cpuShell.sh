#!/bin/bash

JAR_PATH="/home/ubuntu/jar/step01_basic-0.0.1-SNAPSHOT.jar"
LOG_FILE="/var/log/spring-log.log"
MEMORY_THRESHOLD=80  # 메모리 사용량 80% 이상일 때 재시작
APP_NAME="step01_basic"

while true; do
    echo "--------------------" >> $LOG_FILE
    echo "$(date) - Monitoring Spring Boot Application" >> $LOG_FILE

    # 애플리케이션 PID 찾기
    PID=$(pgrep -f "$JAR_PATH")

    if [ -z "$PID" ]; then
        echo "[$(date)] - Application is not running. Restarting..." | tee -a $LOG_FILE
        nohup java -jar $JAR_PATH > /var/log/spring-log.log 2>&1 &
        echo "[$(date)] - Application restarted" | tee -a $LOG_FILE
    else
        # Uptime 확인
        UPTIME=$(ps -p $PID -o etime= | awk '{$1=$1};1')
        echo "[$(date)] - Uptime: $UPTIME" | tee -a $LOG_FILE

        # CPU 부하율 확인
        CPU_LOAD=$(top -b -n 1 -p $PID | grep "$PID" | awk '{print $9}')
        echo "[$(date)] - CPU Load: $CPU_LOAD%" | tee -a $LOG_FILE

        # 메모리 사용량 확인
        MEMORY_USAGE=$(top -b -n 1 -p $PID | grep "$PID" | awk '{print $10}')
        echo "[$(date)] - Memory Usage: $MEMORY_USAGE%" | tee -a $LOG_FILE

        # 메모리 사용량이 임계치를 넘으면 애플리케이션 재시작
        MEMORY_INT=${MEMORY_USAGE%.*}
        if [ "$MEMORY_INT" -gt "$MEMORY_THRESHOLD" ]; then
            echo "[$(date)] - Memory usage exceeded threshold ($MEMORY_THRESHOLD%). Restarting application..." | tee -a $LOG_FILE
            kill -9 $PID
            nohup java -jar $JAR_PATH > /dev/null 2>&1 &
            echo "[$(date)] - Application restarted" | tee -a $LOG_FILE
        fi
    fi

    sleep 60  # 1분마다 체크
done
