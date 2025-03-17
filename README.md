<img src="https://capsule-render.vercel.app/api?type=waving&color=00C3FF&height=150&section=header" width="1000" />

<div align="center">
<h1 style="font-size: 36px;">🔎 Linux-Log-Configuration</h1>
</div>
</br>

### [🙆🏻‍♂️ 팀원](#목차)

#### 팀명 : Ctrl-4
우리FISA 4기 클라우드 엔지니어링 Ctrl-4팀

|<img src="https://avatars.githubusercontent.com/u/150774446?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/55776421?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/179544856?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/129985846?v=4" width="150" height="150"/>|
|:-:|:-:|:-:|:-:|
|김예진<br/>[@yeejkim](https://github.com/yeejkim)|이슬기<br/>[@seulg2027](https://github.com/seulg2027)|이은준<br/>[@2EunJun](https://github.com/2EunJun)|정파란<br/>[@BlueRedOrange](https://github.com/BlueRedOrange)|

<br>

🚀 **프로젝트 개요**

### **목표**

- 로그 파일에서 특정 오류 메시지를 자동 감지 (grep 활용)

- 오류 발생 시 관리자에게 알림 전송 또는 자동 대응 (mail, systemctl restart 등)

- 시스템 안정성을 높이고 수동 개입 없이 문제 해결 가능하도록 자동화

### **자동화 흐름**

- 로그 파일을 주기적으로 확인 (cron 활용)

- 특정 오류 패턴 감지 (grep 사용)

- 오류 발생 시 대응 수행

- 관리자 알림 전송 (SLACK 활용)

- 서비스 자동 재시작 (systemctl restart 활용)

- 감지된 오류 별도 로그 저장 (>> 활용)

- uptime 부하율 감지 및 임계치 초과 시 자동 재부팅


---
⚡ 오류 감지 및 대응 자동화 스크립트
---
📌 크론탭 등록 (5분마다 실행)
---


# Linux-Log-Configuration
Linux를 활용해서 어플리케이션의 로그를 자동으로 분석

# Log 파일 분석하기
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



### Slack 알림전송
![image](https://github.com/user-attachments/assets/83266452-9b4a-4c30-bad7-a97fad979f11)

![image](https://github.com/user-attachments/assets/2769daa5-3e0d-438d-9552-d6a4d873f557)

![image](https://github.com/user-attachments/assets/b7929580-dd95-4687-ab3d-80adc765b985)

![image](https://github.com/user-attachments/assets/3f48fde4-e12e-4fa8-ba4a-b9cf245aedad)

