# 5일차. 스트리밍 파이프라인 실습
> 로컬 경로에 주기적으로 생성되는 파일을 `플루언트디`를 통해 **카프카**에 저장하고, 이렇게 저장된 데이터를 `스파크 스트리밍`을 통해 변환(enrich) 후, **카프카**에 다시 저장한 뒤, **드루이드** `카프카 적재기`를 통해서 드루이드 테이블로 적재 후, **터닐로**를 통해 실시간 지표를 조회하는 실습을 합니다  

> 전체 파이프라인은 `tsv@file -> fluentd -> json@kafka -> spark-streaming -> json@kafka -> druid -> turnilo` 순서대로 흘러갑니다  

## 1. 최신버전 업데이트
> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 과거에 실행된 컨테이너가 없는지 확인하고 종료합니다  

### 1-1. 최신 소스를 내려 받습니다
> 자주 사용하는 명령어는 `alias` 를 걸어둡니다  

```bash
# terminal
cd /home/ubuntu/work/data-engineer-advanced-training
git pull

# alias
alias d="docker-compose"
```

### 1-2. 이전에 기동된 컨테이너가 있다면 강제 종료합니다
```bash
# terminal 
docker rm -f `docker ps -aq`
`docker ps -a` 명령으로 결과가 없다면 모든 컨테이너가 종료되었다고 보시면 됩니다
```

### 1-3. 실습을 위한 이미지를 내려받고 컨테이너를 기동합니다
```bash
# 컨테이너 기동
cd /home/ubuntu/work/data-engineer-advanced-training/day5
docker-compose pull
docker-compose up -d

# 컨테이너 확인
docker-compose ps

# 컨테이너 접속 (fluentd, kafka)
docker-compose exec fluentd bash
docker-compose exec kafka bash
```


## 2. 로컬 파일을 `fluentd`를 통해 `kafka` movies 토픽으로 전송

### 2-1. `fluentd` 컨테이너에 접속하여 http 더미 에이전트를 실행합니다
> 홈 경로가 `/home/root` 이며 해당 경로에 `fluentd` 스크립트가 존재합니다  

* http 서버를 특정 포트로 띄우고 debug 출력을 하는 예제
```xml
<source>
	type http
	port 9881
</source>
<match debug>
	type stdout
</match>
```

* http 소스 에이전트 실행 - default: `/etc/fluentd/fluent.conf`
```bash
# ./fluentd
./fluentd -c /etc/fluentd/fluent.conf
```
* curl 명령을 통해서 테스트
```bash
curl -X POST -d 'json={"message":"hello"}' localhost:9881/debug
```

### 2-2. 로컬 파일을 읽어서 콘솔로 출력하는 예제를 생성합니다
> 디버깅 출력을 위한 match 설정은 그대로 두고,  `/fluentd/source/movies.tsv` 파일을 읽어서 `debug` 태그를 붙여서 출력하도록 `fluent.conf` 파일을 생성하세요  

* tail 플러그인을 통하여 파일을 읽는 소스 설정을 생성합니다
	* [2일차 스트리밍 파일 수집](#4-1-2-플루언트디-파일-구성-fluentconf) 참고하여 `/fluentd/config/file-source.conf`작성합니다
```xml
<source>
    @type tail
    @log_level info
    path "*수집 대상 파일명 혹은 경로*"
    pos_file /fluentd/source/movies.pos
    refresh_interval 10
    multiline_flush_interval 10
    rotate_wait 10
    open_on_every_update true
    emit_unmatched_lines true
    read_from_head true
    tag "*태그*"
    <parse>
        @type tsv
        time_type unixtime
        time_key time
        keys time,movie,title,title_eng,year,grade
        types time:integer,movie:string,title:string,title_eng:string,year:integer,grade:string
    </parse>
</source>
<match "*태그*">
	type stdout
</match>
```

* 디버깅 출력이 정상인지 확인합니다
```bash
./fluentd -c /fluentd/config/file-source.conf
```


## 3.
## 4.
## 5.
## 6.
## 7.

## 2. 실습 환경 구성
* [완료] file -> fluentd -> kafka
	* source: movies@tsv
	* target: movies@kafka
	* fluentd file.in 구성 [tail](https://docs.fluentd.org/input/tail), [tsv](https://docs.fluentd.org/parser/tsv), [parse](https://docs.fluentd.org/configuration/parse-section)
	* fluentd kafka.out 플러그인 구성 - https://docs.fluentd.org/output/kafka
* [완료] kafka -> spark-streaming -> kafka
	* source: movies@kafka
	* sink: korean_movies@kafka
	* spark-streaming notebook : 읽어는 와 졌지만, 해당 값을 다시 카프카로 저장 시에 오류
* [완료] kafka -> druid-kafka-indexer -> druid
	* source: best-movies@kafka
	* target: best-movies@druid
	* druid kafka-indexer config
* [완료] druid -> turnilo
	* turnilo druid config

## 3. 실습 커맨드라인
```bash
cd opt/kafka ; boot="--bootstrap-server localhost:9093"
./fluentd -c /etc/fluentd/file-to-kafka.conf
d run turnilo turnilo --druid http://druid:8082 --print-config --with-comments
```

## 레퍼런스
[Java. Duration](https://docs.oracle.com/javase/8/docs/api/java/time/Duration.html)
[fluentd kafka](https://docs.fluentd.org/output/kafka)
[fluentd tail](https://docs.fluentd.org/input/tail)