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
![image](https://github.com/user-attachments/assets/83266452-9b4a-4c30-bad7-a97fad979f11)

![image](https://github.com/user-attachments/assets/2769daa5-3e0d-438d-9552-d6a4d873f557)

![image](https://github.com/user-attachments/assets/b7929580-dd95-4687-ab3d-80adc765b985)

![image](https://github.com/user-attachments/assets/3f48fde4-e12e-4fa8-ba4a-b9cf245aedad)

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
