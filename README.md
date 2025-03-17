<img src="https://capsule-render.vercel.app/api?type=waving&color=00C3FF&height=150&section=header" width="1000" />

<div align="center">
<h1 style="font-size: 36px;">🔎 Linux-Log-Configuration</h1>
</div>
</br>

### 🙆🏻‍♂️ 팀원

#### 팀명 : Ctrl-4
우리FISA 4기 클라우드 엔지니어링 Ctrl-4팀

|<img src="https://avatars.githubusercontent.com/u/150774446?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/55776421?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/179544856?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/129985846?v=4" width="150" height="150"/>|
|:-:|:-:|:-:|:-:|
|김예진<br/>[@yeejkim](https://github.com/yeejkim)|이슬기<br/>[@seulg2027](https://github.com/seulg2027)|이은준<br/>[@2EunJun](https://github.com/2EunJun)|정파란<br/>[@BlueRedOrange](https://github.com/BlueRedOrange)|

<br>

# Linux-Log-Configuration
본 레파지토리는 Linux의 crontab, uptime, shell을 활용해서 어플리케이션의 로그를 자동으로 분석하는 것을 목표로 합니다. 세부 목표는 다음과 같습니다.

1. 에러 발생시 에러 발생 내역을 모니터링하여, 사용자에게 알리기
2. 1분마다 uptime 부하율을 표시 하고, 일정 수준 넘으면 리부팅하기

### 📌 목표

- 로그 파일에서 특정 오류 메시지를 자동 감지 (grep 활용)

- 오류 발생 시 관리자에게 알림 전송 또는 자동 대응 (mail, systemctl restart 등)

- 시스템 안정성을 높이고 수동 개입 없이 문제 해결 가능하도록 자동화

<br/>

# ⚡ 오류 감지 및 대응 자동화 스크립트

### 1. Spring Application 로그 저장 파일 지정
* yml 파일 수정하여 Ubuntu 내 로그 저장 위치 지정하기
```yml
logging:
  file:
    name: /var/log/spring-log.log
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  level:
    root: info
```

* Ubuntu 내 로그 위치 권한 변경하기
```bash
$sudo chmod 777 /var/log
```

* 로그 확인하기
```
tail -f /var/log/spring-log.log
```

### 2. Slack 알림전송
- Incoming Webhooks 앱을 설치, 생성된 WebHook URL 확인.
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/83266452-9b4a-4c30-bad7-a97fad979f11" width="100%"></td>
    <td><img src="https://github.com/user-attachments/assets/2769daa5-3e0d-438d-9552-d6a4d873f557" width="100%"></td>
  </tr>
</table>

- 알림전송 test
```
 curl -X POST -H 'Content-type: application/json' --data '{"text":"서버가 정상 작동 중입니다."}' https://hooks.slack.com/services/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
```

- 정상작동 확인 <br>
![image](https://github.com/user-attachments/assets/3f48fde4-e12e-4fa8-ba4a-b9cf245aedad)

# 🚩 에러 발생시 에러 발생 내역을 모니터링하여 사용자에게 알림 전송
### 1. 모니터링 shell 파일 생성
```sh
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
```
* 권한 부여
```bash
sudo chmod 777 /home/ubuntu/shelldir/detectError.sh
```

* 실행 테스트
```
./home/ubuntu/shelldir/detectError.sh
```

### 2. Crontab으로 배치 자동화하기
* crontab에 등록하기 (crontab -e 명령)
```bash
* * * * * /home/ubuntu/shelldir/detectError.sh
```

* 1분마다 error로그 확인

![alt text](./img/error_log.png)

* slack 알림

![alt text](./img/slack_alert.png)

# 🚩 CPU 부하율 표시하고, 일정 수준 넘으면 리부팅
### 1. 모니터링하는 shell 파일 생성
* uptime을 활용해서 CPU 사용량을 1분마다 모니터링하는 [shell 파일](./shelldir/cpuShell.sh) 생성

```sh
#!/bin/bash

JAR_PATH="/home/ubuntu/jar/step01_basic-0.0.1-SNAPSHOT.jar"
LOG_FILE="/var/log/spring-log.log"
MEMORY_THRESHOLD=80  # 메모리 사용량 80% 이상일 때 재시작
APP_NAME="step01_basic"

while true; do
    echo "--------------------" >> $LOG_FILE
    echo "$(date) - Monitoring Spring Boot Application" >> $LOG_FILE

    # 애플리케이션 PID
    PID=$(pgrep -f "$JAR_PATH")

    if [ -z "$PID" ]; then
        echo "[$(date)] - Application is not running. Restarting..." | tee -a $LOG_FILE
        nohup java -jar $JAR_PATH > /var/log/spring-log.log 2>&1 & # log 파일 넣기
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
```
* 권한 부여
```bash
sudo chmod 777 /home/ubuntu/shelldir/cpuShell.sh
```

* 실행 테스트
```
./home/ubuntu/shelldir/cpuShell.sh
```

### 2. Crontab으로 배치 자동화하기
* crontab에 등록하기 (crontab -e 명령)
```bash
* * * * * /home/ubuntu/shelldir/cpuShell.sh
```

* 1분마다 CPU 사용량 확인 로그

![alt text](./img/cpu_log.png)

* 어플리케이션 재가동 로그

![alt text](./img/ap_restart.png)
