# 5일차. 스트리밍 파이프라인 설계

> 플루언트디를 통해 로그를 수집하여 카프카에 저장하고, 카프카에 저장된 데이터를 스파크 스트리밍을 통해 풍부하게(enrich)하여, 카프카에 다시 저장하고, 이를 드루이드 적재기를 통해서 드루이드 테이블로 적재 후, 터닐로를 통해 실시간 지표를 조회하는 실습을 합니다
> file -> fluentd -> kafka -> spark-streaming -> kafka -> druid -> turnilo


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
cd /home/ubuntu/work/data-engineer-advanced-training/day5
docker-compose pull
docker-compose up -d
```
<br>


## 2. 실습 환경 구성
* file -> fluentd -> kafka
  - source: movies@csv
  - target: movies@kafka
  - fluentd file.in 구성
  - fluentd kafka.out 플러그인 구성 - https://docs.fluentd.org/output/kafka
* kafka -> spark-streaming -> kafka
  - source: movies@kafka
  - sink: best-movies@kafka
  - spark-streaming notebook
* kafka -> druid-kafka-indexer -> druid
  - source: best-movies@kafka
  - target: best-movies@druid
  - druid kafka-indexer config
* druid -> turnilo
  - turnilo druid config




