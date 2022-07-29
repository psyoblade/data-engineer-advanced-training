# 4일차. 아파치 스파크 데이터 변환 스트리밍

> 아파치 스파크를 통해 스트리밍 예제를 실습합니다. 이번 장에서 사용하는 외부 오픈 포트는 4040, 4041, 8888 입니다


## 1. 최신버전 업데이트 테이블

> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 과거에 실행된 컨테이너가 없는지 확인하고 종료합니다

### 1-1. 최신 소스를 내려 받습니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-advanced-training
git pull
```
<br>

### 1-2. 실습을 위한 이미지를 내려받고 컨테이너를 기동합니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-advanced-training/day3
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
> `http://127.0.0.1:8888/?token=87e758a1fac70558a6c4b4c5dd499d420654c509654c6b01` 이러한 형식의 URL 에서 `127.0.0.1` 을 자신의 호스트 이름(`vm<number>.aiffelbiz.co.kr`)으로 변경하여 접속합니다
<br>


## 2. 데이터 변환 스트리밍

### [1. Spark Streaming Introduction](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-1-introduction.html)
### [2. Spark Streaming Basic](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-2-basic.html)
### [3. Spark Streaming Tools](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-3-tools.html)
### [4. Spark Streaming External](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-4-external.html)
### [5. Spark Streaming Aggregate](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-5-aggregate.html)

### [6. Spark Streaming Join](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-6-join.html)

### [7. Spark Streaming Questions](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-stream/lgde-spark-stream-7-questions.html)

<br>

## 3. 스파크 스트리밍 질문과 답변

### 3-5. 스트리밍 집계 연산

#### Q1. `Watermark` 가 명시 되지 않은 경우, 어떻게 동작하나요?

>  <kbd>답변</kbd> : `watermark`가 명시되지 않은 `Unbounded Table` 경우 전체 범위에 대해 업데이트 됩니다. 결국 `watermark` 처리는 원하지 않는 데이터를 `drop` 하기 위한 용도로 사용한다고 말할 수 있으며, `backfill` 문제점을 회피하는 용도로 사용한다고 말할 수 있습니다. `virtual table`을 사용하는 관점에서 본다면 기본 설정은 해당 테이블 전체 범위를 조회할 수 있는 것이 당연할 것이며, `watermark` 라는 `filter` 를 적용하여 원하는 대상에 대해서만 조건부 검색을 통해 `sink`한다고 말할 수도 있겠습니다. 무엇보다도 `outputMode` 가 `update`인 경우는 해당 `window` 범위 내의 데이터만 처리하기 때문에 큰 문제가 없지만, `complete`인 경우는 모든 데이터를 유지하기 때문에 `OutOfMemory` 문제가 발생할 수 있다는 점에 유의하여 개발, 운영되어야 합니다



