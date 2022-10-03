# 5일차. 스트리밍 파이프라인 실습

> 로컬 경로에 주기적으로 생성되는 파일을 `플루언트디`를 통해 **카프카**에 저장하고, 이렇게 저장된 데이터를 `스파크 스트리밍`을 통해 변환(enrich) 후, **카프카**에 다시 저장한 뒤, **드루이드** `카프카 적재기`를 통해서 드루이드 테이블로 적재 후, **터닐로**를 통해 실시간 지표를 조회하는 실습을 합니다  

> 전체 파이프라인은 `tsv@file -> fluentd -> json@kafka -> spark-streaming -> json@kafka -> druid -> turnilo` 순서대로 흘러갑니다  

![시스템아키텍처](images/pipeline-architecture.png)

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

## 2. 로컬 파일을 플루언트디를 통해 카프카로 전송

### 2-1. 에이전트 정상 동작을 확인하기 위해 http 더미 에이전트를 실행합니다

>  홈 경로가 `/home/root` 이며 해당 경로에 `fluentd` 스크립트가 존재하며, 카프카 전송 이전에 플루언트디 기동 테스트를 먼저 수행 합니다

* http 서버를 특정 포트로 띄우고 debug 출력을 하는 예제
```xml
# /etc/fluentd/fluent-http.conf

<source>
    type http
    port 9881
</source>
<match debug>
    type stdout
</match>
```

* http 소스 에이전트 실행 - default: `/etc/fluentd/fluent-http.conf`
```bash
# ./fluentd
./fluentd -c /etc/fluentd/fluent-http.conf
```* curl 명령을 통해서 테스트
```bash
curl -X POST -d 'json={"message":"hello"}' localhost:9881/debug
```

### 2-2. 로컬 파일을 읽어서 콘솔로 출력하는 예제를 생성합니다

>   디버깅 출력을 위한 match 설정은 그대로 두고,  `/fluentd/source/sample.tsv` 파일을 읽어서 `debug` 태그를 붙여서 출력하도록 `fluent-debug.conf` 파일을 생성하세요  

* tail 플러그인을 통하여 파일을 읽는 소스 설정을 생성합니다
  * [2일차 스트리밍 파일 수집](https://github.com/psyoblade/data-engineer-advanced-training/tree/lgde/2022/day2) 참고하여 `/fluentd/config/fluent-debug.conf`작성합니다
```xml
# /fluentd/config/fluent-debug.conf

<source>
    @type tail
    @log_level info
    path {수집 대상 파일명 혹은 경로}
    pos_file /fluentd/source/movies.pos
    refresh_interval 10
    multiline_flush_interval 10
    rotate_wait 10
    open_on_every_update true
    emit_unmatched_lines true
    read_from_head true
    tag {태그}
    <parse>
        @type tsv
        time_type unixtime
        time_key time
        keys time,movie,title,title_eng,year,grade
        types time:integer,movie:string,title:string,title_eng:string,year:integer,grade:string
        keep_time_key true
    </parse>
</source>
<match {태그}>
    type stdout
</match>
```

* 디버깅 출력이 정상인지 확인합니다
```bash
./fluentd -c /fluentd/config/fluent-debug.conf
```

### 2-3. kafka 플러그인을 활용하여 movies 토픽으로 메시지를 전송합니다

>   파일소스의 태그를 `debug` 에서 `info`로 변경하고 `kafka` 플러그인 설정을 `/fluentd/config/fluent-sample.conf` 파일을 작성합니다  그리고 `/fluentd/source/sample.pos` 파일을 삭제해야 이전 상태가 초기화 되어 수집됩니다.

* kafka 브로커는 `kafka:9093` 으로 전송되어야 하며, 생성 시에 `movies` 토픽이 생성되어 있으므로 그 쪽으로 전송하면 됩니다.
```xml
# /fluentd/config/fluent-sample.conf

<source>
    @type tail
    @log_level info
    path /fluentd/source/sample.tsv
    pos_file /fluentd/source/sample.pos
    refresh_interval 10
    multiline_flush_interval 10
    rotate_wait 10
    open_on_every_update true
    emit_unmatched_lines true
    read_from_head true
    tag {태그}
    <parse>
        @type tsv
        time_type unixtime
        time_key time
        keys time,movie,title,title_eng,year,grade
        types time:integer,movie:string,title:string,title_eng:string,year:integer,grade:string
        keep_time_key false
    </parse>
</source>

<filter info>
    @type record_transformer
    enable_ruby
    <record>
        timestamp ${Time.at(time).strftime('%Y-%m-%dT%H:%M:%S%z')}
    </record>
</filter>

<match info>
    @type kafka2

    brokers {카프카주소:포트}
    use_event_time false

    <buffer topic>
        @type file
        path /var/log/td-agent/buffer/td
        flush_interval 5s
    </buffer>

    <format>
        @type json
    </format>

    default_topic {카프카토픽}
    required_acks -1
    compression_codec gzip
</match>
```

* 파일 소스와 카프카 매치 구성이 완료되었다면 전송 테스트를 합니다
	* 이전에 생성 했던 pos 파일이 삭제 되어야 정상 전송이 됩니다.
```bash
rm /fluentd/source/sample.pos
./fluentd -c /fluentd/config/fluent-sample.conf
```


### 2-4. kafka 콘솔 컨슈머를 활용하여 movies 토픽 메시지를 확인합니다
> 카프카에 정상적으로 메시지가 적재되는지 확인합니다  

* 카프카 설치 경로 `/opt/kafka` 로 이동하여 콘솔 컨슈머를 통해 확인합니다
	* 자주 사용하는 `--bootstrap-server` 옵션은 변수로 저장해 둡니다
```bash
d exec kafka bash
cd /opt/kafka
boot="--bootstrap-server localhost:9093"
bin/kafka-console-consumer.sh $boot --topic movies --from-beginning --max-messages 5
```

## 3. 스파크 스트리밍을 통해 카프카 토픽으로 데이터를 전송합니다

>  카프카 `movies` 토픽을 스파크 스트리밍을 통해 변환 후, 카프카 `korean_movies` 토픽으로 전송합니다.

### 3-1. 노트북을 열어서 스파크 세션을 생성 후, 스파크 버전을. 확인합니다

* 노트북 접속을 위해 주소를 확인하여 브라우저에서 접속합니다
	* 단, 클라우드 환경인 경우에는 클라우드 노드의 주소를 `127.0.0.1` 대신에 넣어야 합니다
```bash
docker-compose logs notebook | grep 127
# [JupyterLab](http://127.0.0.1:8888/lab?token=d0ffa88b4ca509687f7a6502e4376f1bbf192bd8462f83c2)
```

* 스파크 세선을 성성하고 버전을 확인합니다.
	* 상세한 가이드는 [Spark Streaming + Kafka Integration Guide (Kafka broker version 0.10.0 or higher) - Spark 3.2.1 Documentation](https://spark.apache.org/docs/3.2.1/streaming-kafka-0-10-integration.html) 를 참고 합니다.
```python
from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from IPython.display import display, display_pretty, clear_output, JSON

spark = (
    SparkSession
    .builder
    .config("spark.sql.session.timeZone", "Asia/Seoul")
    .getOrCreate()
)

# 노트북에서 테이블 형태로 데이터 프레임 출력을 위한 설정을 합니다
spark.conf.set("spark.sql.repl.eagerEval.enabled", True) # display enabled
spark.conf.set("spark.sql.repl.eagerEval.truncate", 100) # display output columns size

# 공통 데이터 위치
home_jovyan = "/home/jovyan"
work_data = f"{home_jovyan}/work/data"
work_dir=!pwd
work_dir = work_dir[0]

# 로컬 환경 최적화
spark.conf.set("spark.sql.shuffle.partitions", 5) # the number of partitions to use when shuffling data for joins or aggregations.
spark.conf.set("spark.sql.streaming.forceDeleteTempCheckpointLocation", "true")

# 현재 기동된 스파크 애플리케이션의 포트를 확인하기 위해 스파크 정보를 출력합니다
spark
```

* 노트북에서 스파크 스트리밍 상태 및 데이터 조회를 위한 함수 선언
```python
# 스트림 테이블을 주기적으로 조회하는 함수 (name: 이름, sql: Spark SQL, iterations: 반복횟수, sleep_secs: 인터벌)
def displayStream(name, sql, iterations, sleep_secs):
    from time import sleep
    i = 1
    for x in range(iterations):
        clear_output(wait=True)              # 출력 Cell 을 지웁니다
        display('[' + name + '] Iteration: '+str(i)+', Query: '+sql)
        display(spark.sql(sql))              # Spark SQL 을 수행합니다
        sleep(sleep_secs)                    # sleep_secs 초 만큼 대기합니다
        i += 1

# 스트림 쿼리의 상태를 주기적으로 조회하는 함수 (name: 이름, query: Streaming Query, iterations: 반복횟수, sleep_secs: 인터벌)
def displayStatus(name, query, iterations, sleep_secs):
    from time import sleep
    i = 1
    for x in range(iterations):
        clear_output(wait=True)      # Output Cell 의 내용을 지웁니다
        display('[' + name + '] Iteration: '+str(i)+', Status: '+query.status['message'])
        display(query.lastProgress)  # 마지막 수행된 쿼리의 상태를 출력합니다
        sleep(sleep_secs)            # 지정된 시간(초)을 대기합니다
        i += 1
```

### 3-2. 카프카로부터 메시지 수신을 위한 카프카 리더를 생성합니다

> `earliest` 옵션으로 `kafka:9093` 의 `movies` 토픽으로 부터 메시지를 읽어와서 데이터 변환을 수행합니다.

```python
kafkaReader = (
    spark
  .readStream
  .format("kafka")
  .option("kafka.bootstrap.servers", "카프카주소:카프카포트")
  .option("subscribe", "카프카토픽")
  .option("startingOffsets", "카프카오프셋위치")
  .load()
)
kafkaReader.printSchema()

kafkaSchema = (
    StructType()
    .add(StructField("movie", StringType()))
    .add(StructField("title", StringType()))
    .add(StructField("title_eng", StringType()))
    .add(StructField("year", IntegerType()))
    .add(StructField("grade", StringType()))
    .add(StructField("timestamp", StringType()))
)

kafkaSelector = (
    kafkaReader
    .select(
        col("key").cast("string"),
        from_json(col("value").cast("string"), kafkaSchema).alias("movies")
    )
    .selectExpr("movies.movie as key", "to_json(struct(movies.*)) as value")
)

kafkaSelector.printSchema()
```

### 3-3. 디버깅을 위해 임시로 콘솔 출력을 통해 검증합니다

>  스트리밍 데이터는 디버깅이 상당히 어렵기 때문에 새로운 카프카 토픽 혹은 외부에 저장하기 전에 반드시 눈으로 확인해야 합니다  

* 위에서 선언한 `displayStream` 함수를 활용하여 메시지를 읽어서 출력합니다.
```python
# 노트북 로그 콘솔로 출력
queryName = "consoleSink"
kafkaWriter = (
    kafkaSelector.select("key", "value")
    .writeStream
    .queryName(queryName)
    .format("memory")
    .outputMode("append")
)

checkpointLocation = f"{work_dir}/tmp/{queryName}"
!rm -rf $checkpointLocation

kafkaTrigger = (
    kafkaWriter
    .trigger(processingTime="5 second")
    .option("checkpointLocation", checkpointLocation)
)

# 파이썬의 경우 콘솔 디버깅이 노트북 표준출력으로 나오기 때문에, 별도 메모리 테이블로 조회
kafkaQuery = kafkaTrigger.start()
displayStream(queryName, f"select * from {queryName} order by key desc", 4, 5)
kafkaQuery.stop()
```

### 3-4. 카프카 `movies` 토픽을 새로운 토픽 `korean_movies` 로 출력 합니다

>  예제에서는 거의 원본 그대로를 출력하지만, 실제로는 Dimension 테이블과 Join 을 하거나, 데이터 가공 및 변환 등의 Enrich 단계를 수행하며, 우리 예제 에서는 `kafkaSelect` 부분만 수정하면 됩니다.  

* 새로운 토픽 `korean_movies` 으로 전송을 위해 `kafkaWriter` 코드만 다시 작성합니다. 출력 모드는 반드시 `append` 모드로 수행하여 
```python
# 카프카로 다시 저장
queryName = "kafkaSink"
kafkaWriter = (
    kafkaSelector.select("key", "value")
    .writeStream
    .queryName(queryName)
    .format("kafka")
    .option("kafka.bootstrap.servers", "카프카주소:카프카포트")
    .option("topic", "저장대상카프카토픽")
    .outputMode("출력모드")
)

checkpointLocation = f"{work_dir}/tmp/{queryName}"
!rm -rf $checkpointLocation

kafkaTrigger = (
    kafkaWriter
    .trigger(processingTime="5 seconds")
    .option("checkpointLocation", checkpointLocation)
)

kafkaQuery = kafkaTrigger.start()
displayStatus(queryName, kafkaQuery, 1000, 10)
kafkaQuery.stop()
```

## 4. 카프카 토픽을 드루이드 `kafka-index`를 통해 적재합니다

>  드루이드에는 카프카 토픽에 저장된 데이터를 드루이드 테이블로 색인할 수 있는 엔진을 제공합니다. http://localhost:8088 으로 접속하여 관리자 도구를 통해 적재할 수 있습니다.  

### 4-1. 드루이드 카프카 적재기를 통해 드루이드 테이블 색인을 수행합니다

> 캡쳐된 화면을 통해서 순서대로 진행하면 됩니다.  

* 대시보드에서는 수행할 수 있는 모든 작업을 확인할 수 있습니다
  ![dashboard](images/druid-01-dashboard.png)
* 첫 번째 메뉴`Load data`를 선택하고, `Start a new spec`을 클릭하여 외부 데이터를 입수합니다
  ![load](images/druid-02-load.png)
* `Apache Kafka` 를 선택합니다.
  ![load](images/druid-02-load-kafka.png)
* 접속 가능한 카프카 클러스터의 브로커 `kafka:9093` 및 토픽 `korean_movies`를 입력하고 Preview 를 선택합니다
  ![connect](images/druid-03-connect.png)
  - 여기서 카프카 오프셋 처음(earliest) 혹은 최근(latest)부터를 선택할 수 있습니다
* 입력 데이터의 포맷(json, csv, tsv 등)을 선택합니다
  ![data](images/druid-04-data.png)
* 시간 컬럼을 선택해야 하는데, 표준포맷(yyyy-MM-dd HH:mm:dd)인 `timestamp` 컬럼을 선택합니다
  ![time](images/druid-05-time.png)
  - 시간 컬럼이 없다면 상수값을 넣거나, 선택하여 파싱하는 방법도 있습니다만, 애초에 정상적인 시간을 생성해서 받아오는 것이 좋습니다
* 제공하는 함수 등을 이용하여 컬럼을 추가할 수 있습니다
  ![transform](images/druid-06-transform.png)
  - [druid expression](https://druid.apache.org/docs//0.15.1-incubating/misc/math-expr.html) 페이지를 참고합니다
* 제공하는 필터 함수를 이용하여 원하는 데이터만 필터링 할 수 있습니다
  ![filter](images/druid-07-filter.png)
  - [druid filters](https://druid.apache.org/docs//0.15.1-incubating/querying/filters.html) 페이지를 참고합니다
* 최종 스키마를 결정할 수 있으며, 자동으로 생성되는 숫자 컬럼은 제거합니다
  ![schema](images/druid-08-schema.png)
* 테이블의 파티션 구성을 설계할 수 있습니다
  ![partition](images/druid-09-partition.png)
  - [Segment](https://druid.apache.org/docs/latest/design/segments.html) 설정은 데이터의 특성에 따라 조정이 필요함
  - Segment granularity : 엔진 특성상 Roll-Up을 통해서 성능을 끌어올려야 하므로, 중복가능한 지표의 특성을 고려해야 한다
  - Max rows per segment :
  - Max total rows :
* 성능 및 튜닝을 위한 설정
  ![tune](images/druid-10-tune.png)
  - earliest offset : 여기서 반드시 earliest offset 설정을 True 로 선택해야 현재 시점에 적재된 메시지가 처리됩니다
* 테이블 이름 및 최종 배포 설정
  ![publish](images/druid-11-publish.png)
  - append to existing 
  - log parse exceptions
* 최종 생성된 요청 내역을 확인
  ![json](images/druid-12-json.png)
  - 여기서 내용을 수정하면 앞에서 UI 수정을 다시 해야 하므로, 내용을 잘 이해하는 부분이 아니라면 수정하지 않는 것을 추천합니다
* 최종 결과를 제출하면 타스크 탭으로 이동하여 확인이 가능합니다
  ![tasks](images/druid-13-tasks.png)
  - 모든 색인 및 백그라운드 작업은 `Tasks` 탭에서 수행됩니다
* 정상적으로 작업이 적재되었다면 조회가 가능합니다
  ![query](images/druid-14-query.png)
  - 대상 테이블을 선택하고 실시간 테이블 조회가 가능합니다

## 5. 드루이드 테이블을 터닐로를 통해 시각화 합니다

### 5-1. 터닐로 명령어를 통해서 드루이드 테이블 설정을 생성합니다

> 아래의 명령을 통해서 설정 파일을 생성하고, 수정하여 다시 덮어쓸 수도 있습니다

```bash
docker-compose run turnilo turnilo --druid http://druid:8082 --print-config > turnilo/config/new-confing.yml
```

### 5-2. 터닐로가 드루이드 테이블을 인식하게 하기 위해 컨테이너를 재시작합니다

```bash
docker-compose restart turnilo
```

### 5-3. 웹 페이지를 통해 실시간 지표 조회 및 탐색을 수행합니다

> http://localhost:9091 사이트에 접속합니다

* 접속하면 `korean_movies` 페이지를 확인할 수 있습니다
  ![turnilo-01](images/turnilo-01.png)

* 기본적으로 드래그앤드랍 방식으로 탐험이 가능합니다 
  ![turnilo-02](images/turnilo-02.png)

* 우측의 차트종류에 따라 집계 축이 달라지는 경우가 있으므로 주의합니다
  ![turnilo-03](images/turnilo-03.png)

* 디멘젼의 경우 핀해 두고, 자주 사용하는 필터로 사용할 수 있습니다
  ![turnilo-04](images/turnilo-04.png)

* 데이터입력 시간을 UTC기준으로 적재하고, 타임존에 따라 조회할 수 있습니다
  ![turnilo-05](images/turnilo-05.png)

* 인터벌을 지정하고 주기적으로 리프래시하여 대시보드와 같이 사용할 수 있습니다
  ![turnilo-05](images/turnilo-06.png)

## 6. 실시간 색인을 시뮬레이션 하기 위해 플루언트디를 재기동합니다

> 기존에 기동 되었던 `fluentd-sample.conf` 에이전트를 종료하고, 아래와 같은 설정으로 `/fluentd/config/fluent-live.conf` 파일을 생성하여 다시 기동합니다.

### 6-1 샘플 전송 에이전트를 종료하고 라이브 에이전트를 기동합니다

* 아래와 같이 `fluent-live.conf` 파일을 생성합니다

```yaml
# /fluentd/config/fluent-live.conf

<source>
    @type tail
    @log_level info
    path /fluentd/source/movies/*.tsv
    pos_file /fluentd/source/movies.pos
    refresh_interval 10
    multiline_flush_interval 10
    rotate_wait 10
    open_on_every_update true
    emit_unmatched_lines true
    read_from_head true
    tag info
    <parse>
        @type tsv
        time_type unixtime
        time_key time
        keys time,movie,title,title_eng,year,grade
        types time:integer,movie:string,title:string,title_eng:string,year:integer,grade:string
        keep_time_key false
    </parse>
</source>

<filter info>
    @type record_transformer
    enable_ruby
    <record>
        timestamp ${Time.at(time).strftime('%Y-%m-%dT%H:%M:%S%z')}
    </record>
</filter>

<match info>
    @type kafka2

    brokers kafka:9093
    use_event_time false

    <buffer topic>
        @type file
        path /var/log/td-agent/buffer/td
        flush_interval 5s
    </buffer>

    <format>
        @type json
    </format>

    default_topic movies
    required_acks -1
    compression_codec gzip
</match>
```

* 신규로 생성한 에이전트를 다시 기동합니다

```bash
./fluentd -c /fluentd/config/fluent-live.conf
```

### 6-2. 실시간 로그가 쌓이는 것처럼 로그를 생성합니다

>  먼저 별도의 터미널을 하나 더 열고 `fluentd` 컨테이너에 접속하여 아래와 같이 수행합니다

* `publish.sh` 파일을 통해 실시간으로 로그가 쌓이는 것을 시뮬레이션 합니다.

```bash
# docker-compose exec fluetnd bash

cd /fluentd/source/
./publish.sh movies.tsv
```

* 위의 명령어 수행을 통해서 `/fluentd/source/movies` 경로에 10초에 하나씩 파일이 생성되어 로그가 입수됩니다

### 6-3. 터닐로 화면에서 실시간 지표를 확인합니다

>  `TIMEZONE` 과 `AUTO UPDATE` 활성화를 통해 실시간 지표를 리프래시 할 수 있습니다.

![image-20220911200812839](images/auto-update.png)

## 7. 잘못 적재된 토픽을 삭제하고 다시 적재해야 하는 경우

> 카프카의 경우 메시지의 일부 혹은 특정 구간을 삭제하는 방법은 없습니다. 임의의 오프셋 이후부터 적재 혹은 가장 마지막 시점부터 수행하는 방법이 어렵다면 모든 토픽을 삭제하고 다시 생성하는 방법을 선택할 수 있습니다.  

### 7-1. 드루이드 색인을 중지합니다

* 가장 먼저 `Tasks` 탭에서 실행 중인 `Supervisors`를 `Suspend` 상태로 변경  합니다

![image-20220911201008857](images/druid-reset.png)

* 실행 중인 `Tasks`가 있다면 `Kill` 하여 색인을 중지합니다

![image-20220911201203012](images/druid-kill-task.png)

* `Suspend` 상태의 `Supervisor`를 순차적으로 `Reset` 및 `Terminate` 작업을 통해 종료합니다

![image-20220911201405794](images/druid-terminate-index.png)

* `Datasources` 탭에서 삭제 대상 콜렉션을 선택하고 순차적으로 `Drop datasource` 와 `Delete unused Segments`를 선택하여 완전히 삭제 합니다

![image-20220911201554754](images/druid-drop-datasource.png)

>  이렇게 하면 드루이드에서 수행중인 모든 작업과 색인이 삭제 되었습니다.

### 7-2. 스파크 스트리밍 작업을 종료합니다.

>  스파크 스트리밍 작업이 실행 중에 있다면 토픽이 계속 생성될 수 있으므로 종료 후 다시 재기동 해야 합니다.

* 주피터 노트북에서 `Restart kernel` 메뉴를 통해서 스파크 커널을 재시작합니다.

![image-20220911201819337](images/restart-spark-stream.png)

### 7-3. 카프카 토픽을 모두 삭제합니다

> 필요하다면 과거 데이터 모두를 삭제해야 할 수 있으므로 소스, 타깃 토픽을 모두 삭제합니다.

```bash
# docker-compose exec kafka bash

cd /opt/kafka
boot="--bootstrap-server localhost:9093"

# 토픽목록
bin/kafka-console-consumer.sh $boot --list

# 토픽삭제 : bin/kafka-topics.sh $boot --delete --topic "토픽이름"
bin/kafka-console-consumer.sh $boot --from-beginning --topic movies
bin/kafka-console-consumer.sh $boot --from-beginning --topic korean_movies
```

### 7-4. 플루인트디 임시 파일을 삭제합니다.

> 기동 중인 에이전트가 있다면 모두 종료하고 임시 경로에 파일을 모두 삭제합니다.

```bash
# docker-compose exec fluentd bash 

cd /fluentd/source
rm -r movies/*.tsv
```

> 여기까지 수행 되었다면 처음 실습을 시작하는 환경으로 모든 상태가 리셋 되었다고 말할 수 있습니다.

## 8. 도커 컨테이너가 정상동작하지 않는 경우

* 데스크톱 환경에서는 도커 데스크톱을 재시작 하면 되지만 리눅스 환경의 경우는 서비스를 재기동 해야만 합니다.
```bash
sudo systemctl restart docker.service
```


## 레퍼런스
* [java. duration](https://docs.oracle.com/javase/8/docs/api/java/time/Duration.html)
* [fluentd parse](https://docs.fluentd.org/configuration/parse-section)
* [fluentd kafka](https://docs.fluentd.org/output/kafka)
* [fluentd tail](https://docs.fluentd.org/input/tail)
* [fluentd tsv](https://docs.fluentd.org/parser/tsv)
