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

