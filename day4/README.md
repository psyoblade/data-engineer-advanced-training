# 4일차. 아파치 스파크 데이터 변환 스트리밍

> 아파치 스파크를 통해 스트리밍 예제를 실습합니다. 이번 장에서 사용하는 외부 오픈 포트는 4040, 4041, 8888 입니다


## 1. 최신버전 업데이트 테이블

> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 과거에 실행된 컨테이너가 없는지 확인하고 종료합니다

### 1-1. 최신 소스를 내려 받습니다
```bash
# terminal
cd ~/work/data-engineer-advanced-training
git pull
```
<br>

### 1-2. 실습을 위한 이미지를 내려받고 컨테이너를 기동합니다
```bash
# terminal
cd ~/work/data-engineer-advanced-training/day3
docker-compose pull
docker-compose up -d
```
<br>

### 1-3. 스파크 실습을 위해 노트북 페이지에 접속합니다

> 노트북 로그를 확인하여 접속 주소와 토큰을 확인합니다

```bash
# terminal
docker-compose ps

sleep 5
docker-compose logs notebook
```
>  클라우드에서 실습을 하는 경우에는 `http://127.0.0.1:8888/?token=87e758a1fac70558a6c4b4c5dd499d420654c509654c6b01` 이러한 형식의 URL 에서 `127.0.0.1` 을 자신의 호스트 이름(`my-cloud.host.com`)으로 변경하여 접속합니다
<br>


## 2. 데이터 변환 스트리밍

### [1. Spark Streaming Introduction](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-1-introduction.html)
### [2. Spark Streaming Basic](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-2-basic.html)
### [3. Spark Streaming Tools](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-3-tools.html)
### [4. Spark Streaming External](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-4-external.html)
### [5. Spark Streaming Aggregate](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-5-aggregate.html)

### [6. Spark Streaming Join](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-6-join.html)

<br>

## 3. 스파크 스트리밍 팁

> 스파크 스트리밍 과정에서 사용되는 `용어` , `FAQ` 그리고 `성능튜닝의 방향` 에 대해 간략히 정리하였습니다



### 3.1 용어

#### 1. 일반

##### Q1. `Idempotence` 란 무엇인가요?

> <kbd>답변</kbd> : 함수 또는 애플리케이션을 수행 시에 입력이 동일하다면 결과가 항상 동일해야 하는 특성을 말합니다. 특히 데이터 처리에서 지연되는 로그에 대한 처리를 어떻게 하는 지에 따라 애플리케이션 실행 시마다 결과가 다르게 나올 수 있는데, 이런 경우에 멱등성을 만족하지 못한다고 말할 수 있습니다. 결국 데이터 처리 관점에서는 지연데이터에 대한 처리를 수집 관점에서와 처리 관점 모두 고려해 주어야만 합니다.

##### Q2. `Event-time` 과 `Processing-time` 은 어떻게 다른가요?

> <kbd>답변</kbd> : `Event-time` 은 실제 사건 혹은 이벤트가 발생한 시간 (핸드폰에서 특정 광고를 클릭한 시간) 을 말하며 `Processing-time` 은 데이터를 처리하는 서버 혹은 브로커 등에 수신된 시간 (광고 클릭한 메시지가 유/무선 네트워크를 거쳐서 서버에 도착한 시간)을 말합니다

##### Q3. `Bounded` 와 `Unbounded` 의 용어는 무엇을 말하나요?

> <kbd>답변</kbd> : `Bounded` 란 데이터를 처리하는 시점에 대상 데이터의 범위가 명확한 경우를 말합니다. (예: 2022/10/02 0시 ~ 24시). 즉, 실행하는 시점과 무관하게 항상 대상 데이터의 입력과 출력은 멱등하게 동작할 수 있습니다. `Unbounded` 는 데이터를 처리하는 시점에 따라 다른 경우를 말하며, 스트리밍 데이터와 같이 현재 지속적으로 수신되고 있는 데이터에 대한 상태를 말합니다 (예: 최근 30분간 접속한 이용자의 수)

##### Q4. `Epoch` 가 뭔가요?

> <kbd>답변</kbd> : 컴퓨터의 시계 및 타임스탬프 값이 결정되는 날짜와 시간을 말하는데, `Unix` 의 경우 1970년 1월 1일 0시 0분을 [Epoch Time](https://www.techtarget.com/searchdatacenter/definition/epoch) 이라고 말하며, 현재 시간을 epoch time 이후 까지의 초를 말합니다.

#### 2. 스파크 관련

##### Q1. `Structured API` 가 뭔가요?

> <kbd>답변</kbd> : 일반적인 함수 혹은 메소드 형식의 API 와 다르게, 데이터프레임을 통하여 다양한 메소드를 연결하여 활용할 수 있는 구조를 가졌기 때문에 구조화된 API 라고 말하는 것 같습니다

##### Q2. `DStream` 과 `Structured Streaming` 은 어떻게 차이가 나는지?

> <kbd>답변</kbd> :  `DStream` 은 `Spark 1.x` 버전 부터 제공했던 `RDD` 를 활용한 스트리밍 인터페이스이며, 현재는 사용하지 않으며, `Structured Streaming` 은 `Spark 2.x` 부터 지원하는 `DataFrame` 기반의 스트리밍 처리 인터페이스를 말합니다.

##### Q3. `Source` 와 `Sink` 는 뭔가요?

> <kbd>답변</kbd> : `Source` 는 처리해야 하는 원천 데이터, 즉 입력 데이터를 말하며, `Sink` 는 처리된 데이터 혹은 집계 데이터 결과를 저장하는 혹은 전송하는 대상 위치 혹은 서비스를 말합니다.

##### Q4. `Incrementalization` 이라는 개념이 이해가 안됩니다

> <kbd>답변</kbd> : 스트리밍 처리에서는 `Unbounded` 데이터를 마치 정적인 데이터 처럼 동작하게 하면서 가상의 테이블을 이용하여 처리하게 됩니다. 여기서 마치 스파크 배치 작업에서와 같은 **쿼리 수행을 스트리밍 실행 계획으로 변환**하는 과정을 `증분화(Incrementalization)` 이라고 말합니다. 마치 배치 처리를 통해 가상의 테이블에 주기적으로 계속 저장 하는 것처럼 보이지만 내부적으로는 스트리밍 처리 실행 계획을 작성하고 매 배치 실행마다 해당 계획을 실행하여 **마이크로 배치 작업을 수행** 하게 됩니다.

##### Q5. `Materializing` 이란 뭔가요?

> <kbd>답변</kbd> : `DataFrame` 을 처리할 때에 `Lazy Evaluation` 과정을 거쳐서 수행이 되는데, `Not Materialized` 라고 표현되었다면 이는 **아직 실행 계획이 검토되지 않았다**라고 말할 수 있습니다. 즉, `Materialized` 되었다는 말은 **실행 계획을 통해 대상 데이터가 메모리에 올라와 접근할 수 있는 상태**라고 말할 수 있습니다. 또한 논리적인 테이블 관점에서 보았을 때에 `createOrReplaceTempView` 와 같은 가상의 테이블은 메타 정보만 가진 (내부적으로는 실행 계획을 통해서 수행되는 논리적인 테이블) 것이 `Not Materialized` 라고 말할 수 있고, 실제로 `saveAsTable` 과 같은 명령을 통해서 물리적인 저장 경로에 생성된 상태를 `materialized` 되었다고 말할 수 있습니다.

##### Q6. `Micro-batch` 란 어떤 의미인가요?

> <kbd>답변</kbd> : 스파크의 `Structured Streaming` 처리는 엄밀히 얘기하면 `Continuous Streaming` 처리가 아니며 500ms 수준의 작은 배치 작업으로 쪼개어 `incrementalization` 과 같은 증분화 과정을 통해서 *스트리밍 처리를 마치 배치처리와 유사(deterministic)하게*  동작하게 만드는 기법이 '마이크로 배치' 작업입니다. 결국 스파크에서 수행할 수 있는 최소 실시간 수준은 `500ms` 입니다.



### 3.2 자주 하는 질문

#### 1. 스트리밍 일반

##### Q1. 스트리밍 애플리케이션은 실행계획 확인이 가능한가요?

> <kbd>답변</kbd> : `dataFrame` 이 아니라, `query` 객체를 통해 확인할 수 있는데, `query.processAllAvailable()` 혹은 `query.exaplin()` 명령을 통해서 확인할 수 있습니다

##### Q2. 스트리밍 처리가 1초 단위로 실행되지 않는 것 처럼 보일때가 있는데, 왜 그런가요?

> <kbd>답변</kbd> : 내부 트리거링은 계속 발생하지만 (1초) 데이터 소스로부터 가져올 데이터가 없는 경우는 수행되지 않는 것처럼 보일 수 있습니다. 화면에 출력되는 경우는 최종 출력 싱크에 결과 `output` 데이터가 존재하는 경우에만 보이기 때문에 그렇습니다.

##### Q3. 스트리밍 애플리케이션 트리거는 언제 언제 수행되나요?

> <kbd>답변</kbd> : 몇 가지 기준에 따라 수행될 수 있습니다. `1: 맨 처음 스트리밍 애플리케이션이 기동 될 때`, `2: 데이터 소스에 처리할 데이터가 존재할 때`, 그리고 `3. 지정된 임계 시간이 지난 경우` 이런 상황에 만족하게 되는 경우 실행됩니다. 추가로 [Spark Streaming Triggers](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#triggers) 항목을 살펴보시면 좀 더 정확한 트리거링을 확인 할 수 있습니다. 기본 트리거는 지정한 시간을 인터벌로 수행되며, 이전 `microbatch` 작업이 종료되지 않으면 다음 작업은 실행하지 않고 대기하게 됩니다.

##### Q4. 스트리밍 애플리케이션은 반드시 스키마를 지정해야 하나요?

> <kbd>답변</kbd> : 스트리밍 애플리케이션은 24시간 계속 떠 있어야 하기 때문에 자칫 하나의 레코드 혹은 컬럼의 타입 오류에 따라서 전체 파이프라인이 멈추는 경우가 발생하기 때문에 반드시 `spark.readStream.schema(schema)` 와 같이 명시적으로 정의 되어야만 합니다. `dataFrame` 배치 처리의 `inferSchema` 와 같은 옵션은 지원하지 않습니다.

##### Q5. 스트리밍 애플리케이션의 입력 소스로 파일을 지정할 수 없나요?

> <kbd>답변</kbd> : 스파크 스트리밍은 하나의 파일이 아니라 지속적인 스트리밍 데이터를 처리하도록 고안 되었기 때문에, 입력 소스는 파일이 아니라 경로를 입력해야만 합니다. 그렇지 않으면 ``java.lang.IllegalArgumentException: Option 'basePath' must be a directory` 와 같은 오류를 반환하게 됩니다.

#### 2. 스트리밍 집계

##### Q1. `Watermark` 가 명시 되지 않은 경우, 어떻게 동작하나요?

>  <kbd>답변</kbd> : `watermark`가 명시되지 않은 `Unbounded Table` 경우 전체 범위에 대해 업데이트 됩니다. 결국 `watermark` 처리는 원하지 않는 데이터를 `drop` 하기 위한 용도로 사용한다고 말할 수 있으며, `backfill` 문제점을 회피하는 용도로 사용한다고 말할 수 있습니다. `virtual table`을 사용하는 관점에서 본다면 기본 설정은 해당 테이블 전체 범위를 조회할 수 있는 것이 당연할 것이며, `watermark` 라는 `filter` 를 적용하여 원하는 대상에 대해서만 조건부 검색을 통해 `sink`한다고 말할 수도 있겠습니다. 무엇보다도 `outputMode` 가 `update`인 경우는 해당 `window` 범위 내의 데이터만 처리하기 때문에 큰 문제가 없지만, `complete`인 경우는 모든 데이터를 유지하기 때문에 `OutOfMemory` 문제가 발생할 수 있다는 점에 유의하여 개발, 운영되어야 합니다

##### Q2. `AnalysisException`와 같은 오류로 집계 함수 출력이 안되는데 왜 그런가요?

> <kbd>답변</kbd> : 끝없이 발생하는 지표에 대해서 `Stateful` 한 연산인 `집계(Aggregate)` 연산을 위해서는 해당 타임 슬롯 내에 얼마나 지연되는 데이터 까지만 수신할 지에 대한 제약 조건인 `Watermark` 정보가 없으면 아래와 같은 메시지를 발생하면서 오류가 발생합니다. ``AnalysisException: Append output mode not supported when there are streaming aggregations on streaming DataFrames/DataSets without watermark`. 

#### 3. 기타

##### Q1. 카프카 엔진의 포트는 9092 라고 알고 있는데, 실습에서는 9093 포트를 사용하나요?

> <kbd>답변</kbd> : 카프카의 기본 포트는 9092 포트가 맞습니다. 하지만, `docker-compose.yml` 설정과 같이 `KAFKA_ADVERTISED_LISTENERS: INSIDE://kafka:9093,OUTSIDE://localhost:9092` 와 같이 설정되어 있는데 이는 내부 통신의 경우 보안에 신경쓰지 않고 통신하여 부하를 줄이기 위함입니다. 결국 컨테이너 외부에서 접근 시에는 `9092` 포트를 사용해야만 합니다.



### 3.3 성능 개선 방향

#### 1. 스트리밍 애플리케이션

##### Q1. 클러스터 리소스 (Cluster Resource Provisioning)

> <kbd>답변</kbd> : 24/7 서비스를 수행하기 위해 적절한 리소스 프로비저닝이 필수적입니다. 다만, 너무 많은 리소스 할당은 낭비를 초래하고, 적으면 작업이 실패하게 됩니다.  `stateless` 쿼리는 *코어가 많이 필요* 하지만, `stateful` 쿼리는 상대적으로 *메모리를 많이 사용하는 경향* 이 있으므로 쿼리의 성격에 따라 조정합니다

##### Q2. 카프카 파티션 수 (Number of partitions for kafka)

> <kbd>답변</kbd> : 데이터를 병렬로 처리할 수 있는 유일한 방법이 카프카와 같은 클러스터의 파티션 수를 조정하는 방법이며, 이와 동일한 수의 스파크 애플리케이션을 수행할 수 있습니다. 다만, 카프카의 파티션의 경우 늘릴 수만 있고, 한 번 늘어난 파티션 수는 줄일 수 없기 때문에 리소스와 데이터의 향후 트랜드를 고려하여 설정해야 합니다. 스파크 스트리밍 애플리케이션의 경우 집계 단계에서 메모리가 부족하여 `OOM(Out Of Memory)` 문제가 발생하는 경우 즉각적인 조치가 상당히 어렵기 때문에 `사전에 대용량 데이터 처리 혹은 워크로드를 가상으로 만들어 적절한 파티션 수를 정하는 것`이 정말 중요합니다 

##### Q3. 소스 비율 리미트 조정 (Setting source rate limits for stability)

> <kbd>답변</kbd> : 급격하게 소스의 인입이 늘어나는 경우(`burst of streaming data`) 리소스를 늘려서 *오버 프로비저닝* 하는 방법도 있겠지만, 입력 되는 소스 데이터를 조정하는 방안도 고려해볼 수 있습니다. 스테이징 수준의 파이프라인을 별도로 구성하지 않는다면 스로틀링(`throttling`)할 수 있는 방법은 없기 때문에 현실적인 대안은 아닐 수 있으나, 스트리밍 파이프라인을 구성하는 경우에 집계가 이루어지는 데이터 파이프라인 앞에 스테이징하는 파이프라인을 구성하는 것을 고려하여 집계 파이프라인에 입력 되는 데이터를 `일정한 데이터 유입을 조정할 수 있는 파이프라인`을 별도로 구성하는 것도 고려해볼 수 있습니다

##### Q4. 다수의 스트리밍 쿼리 (Multiple streaming queries in the same Spark application)

> <kbd>답변</kbd> : 동일한 SparkContext 또는 SparkSession에서 여러 스트리밍 쿼리를 실행하면 fine-grained 된 리소스 공유가 발생할 수 있습니다. 각 쿼리를 실행하면 Spark 드라이버 (즉, 실행중인 JVM)의 리소스가 계속 사용됩니다. 결국, 드라이버가 동시에 실행할 수있는 쿼리 수가 제한되게 되어, 제한에 도달하면 작업 예약에 병목 현상이 발생하거나 (즉, 실행 프로그램을 제대로 활용하지 못함) 메모리 제한을 초과 할 수 있습니다. `별도의 스케줄러 풀에서 실행되도록 설정하여 동일한 컨텍스트의 쿼리간에보다 공정한 리소스 할당을 보장` 할 수 있습니다.

```scala
# Run streaming query1 in scheduler pool1
spark.sparkContext.setLocalProperty("spark.scheduler.pool", "pool1")
df.writeStream.queryName("query1").format("parquet").start(path1)

# Run streaming query2 in scheduler pool2
spark.sparkContext.setLocalProperty("spark.scheduler.pool", "pool2")
df.writeStream.queryName("query2").format("parquet").start(path2)
```

#### 2. 배치 애플리케이션

##### Q1. 파티션 수 (Number of partitions for shuffles)

> <kbd>답변</kbd> : 배치 작업 대비 다소 작은 셔플 파티션의 수를 가지는데, 너무 많은 작업으로 구분하는 것에 따른 오버헤드를 증가시키거나, 처리량을 감소시킬 수 있습니다. 또한 셔플링은 '스테이트풀 오퍼레이션'에 따른 '체크포인팅'의 오버헤드가 커질 수 있다는 점도 유의할 필요가 있기 때문에, 트리거 간격이 수 초~분 내외의 일반적인 `stateful` 작업의 경우 *기본 셔플 값인 200의 2~3배수 내외로 저장* 하는 것이 일반적입니다.
