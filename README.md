# Linux-Log-Configuration
Linux를 활용해서 어플리케이션의 로그를 자동으로 분석

# Log 파일 분석하기
### 1. Spring Application 로그 저장 파일 지정
yml 파일 수정하여 Ubuntu 내 로그 저장 위치 지정하기
```yml
logging:
  file:
    name: /var/log/spring-log.log
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  level:
    root: info
```
