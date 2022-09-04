# 3일차. 스파크 배치 성능 튜닝

> 아파치 스파크를 통해 다양한 변환 예제를 실습합니다. 이번 장에서 사용하는 외부 오픈 포트는 4040, 4041, 8888 입니다


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

>  컨테이너 또한 시스템 메모리를 차지하며, 불필요한 컨테이너는 띄울 필요가 없기 때문에 이번 실습에 필요한 `notebook` 컨테이너만 띄울 것을 추천 드립니다.

```bash
# terminal
cd ~/work/data-engineer-advanced-training/day3
docker-compose pull
docker-compose up -d notebook
```
<br>

### 1-3. 스파크 실습을 위해 노트북 페이지에 접속합니다

> 노트북 로그를 확인하여 접속 주소와 토큰을 확인합니다

```bash
# terminal
docker-compose ps

sleep 10
docker-compose logs notebook
```
>  클라우드에서 실습을 하는 경우에는 `http://127.0.0.1:8888/?token=87e758a1fac70558a6c4b4c5dd499d420654c509654c6b01` 이러한 형식의 URL 에서 `127.0.0.1` 을 자신의 호스트 이름(`my-cloud.host.com`)으로 변경하여 접속합니다

<br>

[목차로 돌아가기](#3일차-스파크-배치-성능-튜닝)

<br>

<br>

## 2. 데이터 변환 기본

>  데이터 엔지니어 중급 과정을 수강하지 않으신 분들을 위한 노트북 환경입니다. `lgde-spark-core` 경로에 포함된 노트북을 열어 "1. 기본" ~ "3. 데이터 타입" 까지 3강을 직접 타이핑 하면서 실습하시고, :green_book: 연습 문제만 직접 풀어보시기 바랍니다

### [1. 아파치 스파크 기본](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-1-basic.html)

### [2. 아파치 스파크 연산자](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-2-operators.html)

### [3. 아파치 스파크 데이터타입](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-3-data-types.html)

### [4. 아파치 스파크 조인](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-4-join.html)
### [5. 아파치 스파크 집계](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-5-aggregation.html)
### [6. 아파치 스파크 JDBC to MySQL](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-6-jdbc-mysql.html)
### [7. 아파치 스파크 JDBC to MongoDB](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-core/lgde-spark-core-7-jdbc-mongodb.html)
<br>

[목차로 돌아가기](#3일차-스파크-배치-성능-튜닝)

<br>

<br>

## 3. 스파크 코어 퀴즈

>  데이터 엔지니어링 중급 과정을 수강하신 분들은 스파크 API 함수의 리마인드 차원에서 퀴즈를 진행해 주시고, 처음 수강하시는 분들은 "**2. 데이터 변환 기본**" 노트북의 코드를 레퍼런스 하시어 실습을 진행해 주시면 고맙겠습니다.

### 3-1. :green_book: 수집된 데이터 탐색

> 스파크 세션을 통해서 수집된 데이터의 형태를 파악하고, 스파크의 기본 명령어를 통해 수집된 데이터 집합을 탐색합니다

#### 3-1-1. 스파크 객체를 생성하는 코드를 작성하고, <kbd><kbd>Shift</kbd>+<kbd>Enter</kbd></kbd> 로 스파크 버전을 확인합니다

```python
# 코어 스파크 라이브러리를 임포트 합니다
from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from IPython.display import display, display_pretty, clear_output, JSON

spark = (
    SparkSession
    .builder
    .appName("Data Engineer Training Course")
    .config("spark.sql.session.timeZone", "Asia/Seoul")
    .getOrCreate()
)

# 노트북에서 테이블 형태로 데이터 프레임 출력을 위한 설정을 합니다
from IPython.display import display, display_pretty, clear_output, JSON
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
spark
```

<details><summary> 정답확인</summary>
> 스파크 엔진의 버전 `v3.1.2`이 출력되면 성공입니다

</details>
<br>


#### 3-1-2. 이용자 데이터를 읽고 확인

>  이용자 데이터를 읽어서 user 라는 변수에 담아서 printSchema 및 display 함수를 써서 스키마와 데이터를 출력하세요

* 이용자 데이터 정보

  - 경로 : <kbd>data/tbl_user.csv</kbd>
  - 포맷 : <kbd>csv</kbd>
  - 옵션 : <kbd>inferSchema=true</kbd> , <kbd>header=true</kbd> 

* 아래의 예제를 활용하세요

  - 입력 포맷이 csv 인 경우는 csv 명령어와 옵션을 사용하세요 <kbd>spark.read.option("inferSchema", "true").csv("target-directory")</kbd> 
  - 모든 데이터에 대한 스키마를 출력하세요 <kbd>dataFrame.printSchema()</kbd> 
  - 데이터 내용을 출력하여 확인하세요 <kbd>dataFrame.show() 혹은 display(dataFrame)</kbd> 

* 이용자 정보 파일을 읽고, 스키마와 데이터 출력하기

  * ```python
    user = <이용자 데이터를 읽어와서 스키마와, 데이터를 출력하는 코드를 작성하세요>
    ```

<details><summary> 정답확인</summary>


> 아래와 유사하게 작성하고, 결과가 같다면 성공입니다

```python
user = (
  spark.read
  .option("inferSchema", "true")
  .option("header", "true")
  .csv("data/tbl_user.csv")
)
user.printSchema()
display(user)
```

```bash
root
 |-- u_id: integer (nullable = true)
 |-- u_name: string (nullable = true)
 |-- u_gender: string (nullable = true)
 |-- u_signup: integer (nullable = true)

u_id	u_name	u_gender	u_signup
1	정휘센	남	19700808
2	김싸이언	남	19710201
3	박트롬	여	19951030
4	청소기	남	19770329
5	유코드제로	여	20021029
6	윤디오스	남	20040101
7	임모바일	남	20040807
8	조노트북	여	20161201
9	최컴퓨터	남	20201124
```

</details>
<br>

### 3-2. :blue_book: 이용자 테이블 가공하기

> 이용자 데이터프레임을 아래의 조건에 맞도록 변환 후, tbl_user 이라는 변수에 담아서, 스키마와 데이터를 출력하세요

#### 3-2-1. 데이터프레임 컬럼 함수를 이용한 가공

* 컬럼 변환 조건

  - 이름 변경 : <kbd>u_signup</kbd> => <kbd>u_register</kbd> 
  - 컬럼 변환 : <kbd>u_name</kbd> 컬럼의 첫 번째 문자를  <kbd>u_family_name</kbd>, 나머지 문자열을  <kbd>u_given_name</kbd> 으로 생성하고, <kbd>u_name</kbd>  컬럼은 삭제 
  - 최종 스키마 : <kbd>u_id, u_gender, u_register, u_family_name, u_given_name</kbd>

* 아래의 예제를 활용하세요

  - 컬럼 이름을 변경할 때에는 컬럼 함수를 사용합니다
    -  <kbd>dataFrame.withColumnRenamed("original", "modified")</kbd> 
  - 새로운 컬럼을 추가하는 함수
    -  <kbd>dataFrame.withColumn("newColumn", expr("column_expression"))</kbd> 
  - 컬럼 삭제하는 함수
    -  <kbd>dataFrame.drop("columnName")</kbd> 

* 조건에 만족하는 이용자 데이터를 변환하세요

  * ```python
    tbl_user = <user 데이터 프레임의 컬럼을 조건에 맞도록 변환하는 코드를 작성하세요>
    ```

<details><summary> 정답확인</summary>


> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
# Structured API 방식
from pyspark.sql.functions import *
tbl_user = (
    user
    .withColumnRenamed("u_signup", "u_register")
    .withColumn("u_family_name", substring("u_name", 0, 1))
    .withColumn("u_given_name", col("u_name").substr(2, len("u_name")))
    .drop("u_name")
)
tbl_user.printSchema()
display(tbl_user)
```

```python
# SQL 표현식을 이용한 방식
from pyspark.sql.functions import *
tbl_user = (
    user
    .withColumnRenamed("u_signup", "u_register")
    .withColumn("u_family_name", expr("substr(u_name, 0, 1)"))
    .withColumn("u_given_name", expr("substr(u_name, 2)"))
    .drop("u_name")
)
tbl_user.printSchema()
display(tbl_user)
```

```bash
root
 |-- u_id: integer (nullable = true)
 |-- u_gender: string (nullable = true)
 |-- u_register: integer (nullable = true)
 |-- u_family_name: string (nullable = true)
 |-- u_given_name: string (nullable = true)

u_id	u_gender	u_register	u_family_name	u_given_name
1	남	19700808	정	휘센
2	남	19710201	김	싸이언
3	여	19951030	박	트롬
4	남	19770329	청	소기
5	여	20021029	유	코드제로
6	남	20040101	윤	디오스
7	남	20040807	임	모바일
8	여	20161201	조	노트북
9	남	20201124	최	컴퓨터
```

</details>
<br>

### 3-3. :blue_book: 매출 테이블과 조인하기

> 매출 데이터를 읽어서 tbl_purchase 이라는 변수에 담고 tbl_user 과 조인하여 fact_daily 변수에 담아서 데이터를 출력하세요

#### 3-3-1. 이용자 테이블과 매출 테이블 조인

* 매출 테이블 정보

  - 경로 : <kbd>data/tbl_purchase.csv</kbd>
  - 포맷 : <kbd>csv</kbd>
  - 옵션 : <kbd>inferSchema=true</kbd> , <kbd>header=true</kbd> 

* 아래의 조건이 만족되어야 합니다

  - 조인 조건
    -  <kbd>`tbl_user.u_id` == `tbl_purchase.p_uid`</kbd>
  - 조인 방식
    -  `tbl_user` 테이블을 기준으로  `left_outer` 조인

* 조건에 만족하는 코드를 작성하세요

  * ```python
    tbl_purchase = "<경로의 매출 데이터를 읽어서 데이터프레임을 생성하는 코드를 작성하세요>"
    tbl_purchase.printSchema()
    display(tbl_purchase)
    
    fact_daily = "<tbl_user 과 tbl_purchase 테이블을 left_outer 조인을 하는 코드를 작성하세요>"
    fact_daily.printSchema()
    display(fact_daily)
    ```


<details><summary> 정답확인</summary>


> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
tbl_purchase = spark.read.option("inferSchema", "true").option("header", "true").csv("data/tbl_purchase.csv")
tbl_purchase.printSchema()
display(tbl_purchase)

fact_daily = tbl_user.join(tbl_purchase, tbl_user.u_id == tbl_purchase.p_uid, "left_outer")
fact_daily.printSchema()
display(fact_daily)
```

```bash
root
 |-- p_time: integer (nullable = true)
 |-- p_uid: integer (nullable = true)
 |-- p_id: integer (nullable = true)
 |-- p_name: string (nullable = true)
 |-- p_amount: integer (nullable = true)

p_time	p_uid	p_id	p_name	p_amount
1603651550	0	1000	GoldStar TV	100000
1603651550	1	2000	LG DIOS	2000000
1603694755	1	2001	LG Gram	1800000
1603673500	2	2002	LG Cyon	1400000
1603652155	3	2003	LG TV	1000000
1603674500	4	2004	LG Computer	4500000
1603665955	5	2001	LG Gram	3500000
1603666155	5	2003	LG TV	2500000
root
 |-- u_id: integer (nullable = true)
 |-- u_gender: string (nullable = true)
 |-- u_register: integer (nullable = true)
 |-- u_family_name: string (nullable = true)
 |-- u_given_name: string (nullable = true)
 |-- p_time: integer (nullable = true)
 |-- p_uid: integer (nullable = true)
 |-- p_id: integer (nullable = true)
 |-- p_name: string (nullable = true)
 |-- p_amount: integer (nullable = true)

u_id	u_gender	u_register	u_family_name	u_given_name	p_time	p_uid	p_id	p_name	p_amount
1	남	19700808	정	휘센	1603694755	1	2001	LG Gram	1800000
1	남	19700808	정	휘센	1603651550	1	2000	LG DIOS	2000000
2	남	19710201	김	싸이언	1603673500	2	2002	LG Cyon	1400000
3	여	19951030	박	트롬	1603652155	3	2003	LG TV	1000000
4	남	19770329	청	소기	1603674500	4	2004	LG Computer	4500000
5	여	20021029	유	코드제로	1603666155	5	2003	LG TV	2500000
5	여	20021029	유	코드제로	1603665955	5	2001	LG Gram	3500000
6	남	20040101	윤	디오스	null	null	null	null	null
7	남	20040807	임	모바일	null	null	null	null	null
8	여	20161201	조	노트북	null	null	null	null	null
9	남	20201124	최	컴퓨터	null	null	null	null	null
```

</details>
<br>


### 3-4. :closed_book: 널 값 처리하기

> fact_daily 데이터를 na 함수를 써서 매출 정보가 널인 경우는 아래의 조건에 맞게 변경하고 fact_daily_na 변수에 담아서 데이터를 출력하세요

#### 3-4-1. 널 값을 처리하기 위한 규칙 적용

* 매출 관련 컬럼 널 값 처리 규칙

  - <kbd>p_time</kbd> : `0`

  - <kbd>p_uid</kbd> : `0`

  - <kbd>p_name</kbd> : `"미확인"`
  - <kbd>p_amount</kbd> : `0`

* 아래의 예제를 활용하세요

  - `na` 함수 사용을 위한 규칙 딕셔너리 정의
    -  <kbd>na_dict = { "column1":defval1, "column2": defval2 }</kbd> 
  - `na` 함수 적용 예제
    -  <kbd>dataFrame.na.fill(na_dict)</kbd> 

* 널 값을 처리하는 코드를 작성하세요

  * ```python
    na_fill = "<널값 처리를 위한 딕셔너리를 완성하세요>"
    fact_daily_na = "<fact_daily 데이터 프레임의 널 값을 처리하는 함수를 작성하세요>"
    ```

<details><summary> 정답확인</summary>

> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
na_fill = {
    "p_time":0,
    "p_uid":0,
    "p_name":"미확인",
    "p_amount":0
}

fact_daily_na = fact_daily.na.fill(na_fill)
fact_daily_na.printSchema()
display(fact_daily_na)
```

```bash
root
 |-- u_id: integer (nullable = true)
 |-- u_gender: string (nullable = true)
 |-- u_register: integer (nullable = true)
 |-- u_family_name: string (nullable = true)
 |-- u_given_name: string (nullable = true)
 |-- p_time: integer (nullable = false)
 |-- p_uid: integer (nullable = false)
 |-- p_id: integer (nullable = true)
 |-- p_name: string (nullable = false)
 |-- p_amount: integer (nullable = false)

u_id	u_gender	u_register	u_family_name	u_given_name	p_time	p_uid	p_id	p_name	p_amount
1	남	19700808	정	휘센	1603694755	1	2001	LG Gram	1800000
1	남	19700808	정	휘센	1603651550	1	2000	LG DIOS	2000000
2	남	19710201	김	싸이언	1603673500	2	2002	LG Cyon	1400000
3	여	19951030	박	트롬	1603652155	3	2003	LG TV	1000000
4	남	19770329	청	소기	1603674500	4	2004	LG Computer	4500000
5	여	20021029	유	코드제로	1603666155	5	2003	LG TV	2500000
5	여	20021029	유	코드제로	1603665955	5	2001	LG Gram	3500000
6	남	20040101	윤	디오스	0	0	null	미확인	0
7	남	20040807	임	모바일	0	0	null	미확인	0
8	여	20161201	조	노트북	0	0	null	미확인	0
9	남	20201124	최	컴퓨터	0	0	null	미확인	0
```

</details>

<br>

### 3-5. :blue_book: 집계 처리하기

> fact_daily_na 데이터프레임을 이용하여 성별 매출 금액의 합계를 출력하세요

#### 3-5-1. 성별 매출 금액의 합계를 추출합니다

* 매출 관련 컬럼 널 값 처리 규칙

  - 결과 스키마 : <kbd>u_gender, sum</kbd>

* 아래의 예제를 활용하세요

  - `groupBy` 함수 사용
    -  <kbd>dataFrame.groupBy("groupColumn").agg(sum("aggColumn"))</kbd> 

* 성별 매출 집계 코드를 작성하세요

  * ```python
    count_by_gender = "<fact_daily_na 데이터프레임을 성별 매출 합계를 계산하는 코드를 작성하세요>"
    ```

<details><summary> 정답확인</summary>

> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
count_by_gender = fact_daily_na.groupBy("u_gender").agg(sum("p_amount").alias("sum"))
display(count_by_gender)
```

```bash
u_gender	sum
여	7000000
남	9700000
```

</details>

<br>

### 3-6. :blue_book: 저장 및 다시 읽어오기

> fact_daily_na 데이터를 json 포맷으로 저장 후, 다시 읽어서 fact_daily_json 변수에 담아 스키마와 데이터를 출력하세요

#### 3-6-1. JSON 포맷으로 저장하고, 다시 읽어옵니다

* 저장 데이터 정보

  - 경로 : <kbd>data/fact_daily/dt=20220727</kbd>

  - 포맷 : <kbd>json</kbd>

  - 모드 : <kbd>overwrite</kbd>

* 아래의 예제를 활용하세요

  - `write` 함수 사용
    -  <kbd>dataFrame.write.option("key", "value").json("target-directory")</kbd> 

* 데이터를 저장 및 읽어오는  코드를 작성하세요

  * ```python
    json_path = "data/fact_daily/dt=20220727"
    "<fact_daily_na 데이터프레임을 json_path 에 저장하는 코드를 작성하세요>"
    fact_daily_json = "<json_path 에 저장된 데이터를 읽어오는 코드를 작성하세요>"
    fact_daily_json.printSchema()
    display(fact_daily_json)
    ```

<details><summary> 정답확인</summary>

> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
json_path = "data/fact_daily/dt=20220727"
fact_daily_na.write.mode("overwrite").json(json_path)
fact_daily_json = spark.read.json(json_path)
fact_daily_json.printSchema()
display(fact_daily_json)
```

```bash
root
 |-- p_amount: long (nullable = true)
 |-- p_id: long (nullable = true)
 |-- p_name: string (nullable = true)
 |-- p_time: long (nullable = true)
 |-- p_uid: long (nullable = true)
 |-- u_family_name: string (nullable = true)
 |-- u_gender: string (nullable = true)
 |-- u_given_name: string (nullable = true)
 |-- u_id: long (nullable = true)
 |-- u_register: long (nullable = true)

p_amount	p_id	p_name	p_time	p_uid	u_family_name	u_gender	u_given_name	u_id	u_register
1800000	2001	LG Gram	1603694755	1	정	남	휘센	1	19700808
2000000	2000	LG DIOS	1603651550	1	정	남	휘센	1	19700808
1400000	2002	LG Cyon	1603673500	2	김	남	싸이언	2	19710201
1000000	2003	LG TV	1603652155	3	박	여	트롬	3	19951030
4500000	2004	LG Computer	1603674500	4	청	남	소기	4	19770329
2500000	2003	LG TV	1603666155	5	유	여	코드제로	5	20021029
3500000	2001	LG Gram	1603665955	5	유	여	코드제로	5	20021029
0	null	미확인	0	0	윤	남	디오스	6	20040101
0	null	미확인	0	0	임	남	모바일	7	20040807
0	null	미확인	0	0	조	여	노트북	8	20161201
0	null	미확인	0	0	최	남	컴퓨터	9	20201124
```

</details>

<br>

### 3-7 :closed_book: 데이터 조회하기

> fact_daily_json 데이터를 상품별 매출 금액의 합계를 구하고 `최대 매출 상품이름`을 확인하세요

#### 3-7-1. Spark SQL 통해 한 번에 조회하기

* 아래의 조건에 따라 수행하세요

  * 결과 스키마 : <kbd>p_name, amount</kbd>

* 아래의 예제를 활용하세요

  - `createOrReplaceTempView` 함수 사용하여 임시 테이블 생성
    -  <kbd>dataFrame.createOrReplaceTempView("table-name")</kbd> 
  - `sql` 함수 사용하여 임시 테이블 조회 쿼리 수행
    -  <kbd>dataFrame = spark.sql("sql-query")</kbd> 

* 데이터를 저장 및 읽어오는  코드를 작성하세요

  * ```python
    "<fact_daily_json 데이터프레임을 임시 테이블을 생성하는 코드를 작성하세요>"
    no_1_product_query = """
    <상품 별 매출금액의 합을 구하는 SQL을 작성하세요
    """
    no_1_product = spark.sql(no_1_product_query)
    display(no_1_product)
    ```

<details><summary> 정답확인</summary>

> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
fact_daily_json.createOrReplaceTempView("fact_daily_json")
no_1_product_query = """
select p_name, sum(p_amount) as sum
from fact_daily_json
group by p_name
order by sum desc
limit 1
"""
no_1_product = spark.sql(no_1_product_query)
display(no_1_product)
```

```bash
p_name	sum
LG Gram	5300000
```

</details>

<br>

#### 3-7-2. Structured API 통해 한 번에 조회하기

* 아래의 조건에 따라 수행하세요

  * 결과 스키마 : <kbd>p_name, amount</kbd>

* 아래의 예제를 활용하세요

  - `groupBy` , `agg(sum("column"))` 함수를 사용하여 집계
    -  <kbd>dataFrame.groupBy("groupColumn").agg(sum("aggColumn").alias("aliasName"))</kbd> 
  - `orderBy` , `desc("column")`을  사용하여 결과를 정렬 (오름차순은 `asc`)
    -  <kbd>dataFrame.orderBy(desc("column"))</kbd> 

* 데이터를 저장 및 읽어오는  코드를 작성하세요

  * ```python
    structured_fact = "<fact_daily_json 데이터프레임을 상품이름으로 매출의 합을 구하는 코드를 작성>"
    display(structured_fact)
    ```

<details><summary> 정답확인</summary>

> 아래의 결과와 유사하게 작성하였고 결과가 같다면 정답입니다

```python
structured_fact = (
	fact_daily_json
  .groupBy("p_name").agg(sum("p_amount").alias("sum"))
  .orderBy(desc("sum")).limit(1)
)
display(structured_fact)
```

```bash
p_name	sum
LG Gram	5300000
```

</details>

<br>

[목차로 돌아가기](#3일차-스파크-배치-성능-튜닝)
<br>
<br>


## 4. 데이터 변환 고급

### [1. Repartition vs. Coalesce](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-1-repartition.html)
### [2. Skewness Problem](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-2-skewness.html)
### [3. Cache, Persist and Unpersist](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-3-cache.html)
### [4. Partitioning Explained](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-4-partition.html)
### [5. Bucketing Explained](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-5-bucket.html)
### [6. Performance Tuning Summary](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-advanced-training/blob/master/day3/notebooks/lgde-spark-troubleshoot/lgde-spark-troubleshoot-6-perf-tuning.html)
<br>

[목차로 돌아가기](#3일차-스파크-배치-성능-튜닝)
