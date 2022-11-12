# 1일차. 데이터 엔지니어링 기본

> 클라우드 장비에 접속하여 인스턴스를 기동하고, 도커 및 컴포즈를 통한 기본 명령어를 학습합니다

- 범례
  * :green_book: : 기본, :blue_book: : 중급, :closed_book: : 고급

- 목차
  * [1. 클라우드 장비에 접속](#1-클라우드-장비에-접속)
  * [2. Docker 명령어 실습](#2-Docker-명령어-실습)
    - [Docker 기본 명령어](#Docker-기본-명령어)
    - [Docker 고급 명령어](#Docker-고급-명령어)
  * [3. Docker Compose 명령어 실습](#3-Docker-Compose-명령어-실습)
    - [Docker Compose 기본 명령어](#Docker-Compose-기본-명령어)
    - [Docker Compose 고급 명령어](#Docker-Compose-고급-명령어)
  * [4. 참고 자료](#4-참고-자료)
  <br>


## 1. 클라우드 장비에 접속

> 개인 별로 할당 받은 `ubuntu@my-cloud.host.com` 에 putty 혹은 terminal 을 이용하여 접속합니다

### 1-1. 원격 서버로 접속합니다

```bash
# terminal
# ssh ubuntu@my-cloud.host.com
# password: ******
```

### 1-2. 패키지 설치 여부를 확인합니다

```bash
docker --version
docker-compose --version
git --version
```

<details><summary>[실습] 출력 결과 확인</summary>

> 출력 결과가 오류가 발생하지 않고, 아래와 같다면 성공입니다

```text
Docker version 20.10.6, build 370c289
docker-compose version 1.29.1, build c34c88b2
git version 2.17.1
```

</details>

### 1-3. 유용한 팁

```bash
# cat ~/.bashrc

export EDITOR="vim"
alias d="docker-compose"
alias dps="docker ps -a"
alias drm="docker rm -f"

alias gl="git log --all --graph --oneline --decorate"
alias gs="git status"
alias gd="git diff"
alias gb="git branch"
alias gp="git pull"
```

> `/etc/hosts` 파일에 등록된 내용이며, `<IP>` 항목과 `vm<number>` 항목을 변경해 두시면 접속 시에 편합니다

```bash
...
<IP> vm<number>.koreacentral.cloudapp.azure.com vm<number>
```

> 도커 컨테이너에 문제가 생겼을 때에 도커 서비스 상태 확인 및 재시작 하는 방법

```bash
sudo systemctl status docker.service
sudo systemctl restart docker.service
```



[목차로 돌아가기](#1일차-데이터-엔지니어링-고급)

<br>
<br>



## 2. Docker 명령어 실습

> 컨테이너 관리를 위한 도커 명령어를 실습합니다

* 실습을 위해 기존 프로젝트를 삭제 후 다시 클론합니다

```bash
# terminal
cd ~/work
rm -rf ~/work/helloworld
git clone https://github.com/psyoblade/helloworld.git
cd ~/work/helloworld
```
<br>

### Docker 기본 명령어

### 2-1. 컨테이너 생성관리

> 도커 이미지로 만들어져 있는 컨테이너를 생성, 실행 종료하는 명령어를 학습합니다

#### 2-1-1. `create` : 컨테이너를 생성합니다 

  - <kbd>--name <container_name></kbd> : 컨테이너 이름을 직접 지정합니다 (지정하지 않으면 임의의 이름이 명명됩니다)
  - 로컬에 이미지가 없다면 다운로드(pull) 후 컨테이너를 생성까지만 합니다 (반드시 -it 옵션이 필요합니다)
  - 생성된 컨테이너는 실행 중이 아니라면 `docker ps -a` 실행으로만 확인이 가능합니다

```bash
# docker create <image>:<tag>
docker create -it ubuntu:18.04
```
<br>

#### 2-1-2. `start` : 생성된 컨테이너를 기동합니다

* 아래 명령으로 현재 생성된 컨테이너의 이름을 확인합니다
```bash
docker ps -a
```

* 예제의 `busy_herschel` 는 자동으로 생성된 컨테이너 이름이며, 변수에 담아둡니다
```bash
# CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS    PORTS     NAMES
# e8f66e162fdd   ubuntu:18.04   "bash"    2 seconds ago   Created             busy_herschel
container_name="<목록에서_출력된_NAME을_입력하세요>"
```

```bash
# docker start <container_name> 
docker start ${container_name}
```

```bash
# 해당 컨테이너의 우분투 버전을 확인합니다
docker exec -it ${container_name} bash
cat /etc/issue
exit
```
<br>


#### 2-1-3. `stop` : 컨테이너를 잠시 중지시킵니다
  - 해당 컨테이너가 삭제되는 것이 아니라 잠시 실행만 멈추게 됩니다
```bash
# docker stop <container_name>
docker stop ${container_name} 
```
<br>


#### 2-1-4. `rm` : 중단된 컨테이너를 삭제합니다
  - <kbd>-f, --force</kbd> : 실행 중인 컨테이너도 강제로 종료합니다 (실행 중인 컨테이너는 삭제되지 않습니다)
```bash
# docker rm <container_name>
docker rm ${container_name} 
```
<br>


#### 2-1-5. `run` : 컨테이너의 생성과 시작을 같이 합니다 (create + start)
  - <kbd>--rm</kbd> : 종료 시에 컨테이너까지 같이 삭제합니다
  - <kbd>-d, --detach</kbd> : 터미널을 붙지않고 데몬 처럼 백그라운드 실행이 되게 합니다
  - <kbd>-i, --interactive</kbd> : 인터액티브하게 표준 입출력을 키보드로 동작하게 합니다
  - <kbd>-t, --tty</kbd> : 텍스트 기반의 터미널을 에뮬레이션 하게 합니다
```bash
# docker run <options> <image>:<tag>
docker run --rm --name ubuntu20 -dit ubuntu:20.04
```
```bash
# 터미널에 접속하여 우분투 버전을 확인합니다
docker exec -it ubuntu20 bash
cat /etc/issue
```
<kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 명령으로 터미널에서 빠져나올 수 있습니다

<br>


#### 2-1-6. `kill` : 컨테이너를 종료합니다
```bash
# docker kill <container_name>
docker kill ubuntu20
```
<br>


### 2-2. 컨테이너 모니터링

#### 2-2-1. `ps` : 실행 중인 컨테이너를 확인합니다
  - <kbd>-a</kbd> : 실행 중이지 않은 컨테이너까지 출력합니다
```bash
docker ps
```

#### 2-2-2. `logs` : 컨테이너 로그를 표준 출력으로 보냅니다

  - <kbd>-f</kbd> : 로그를 지속적으로 tailing 합니다
  - <kbd>-p</kbd> : 호스트 PORT : 게스트 PORT 맵핑
```bash
docker run --rm -p 8888:80 --name nginx -dit nginx
```

```bash
# docker logs <container_name>
docker logs nginx
```

```bash
# terminal
curl localhost:8888
```
> 혹은 `http://vm001.aiffelbiz.co.kr:8888` 브라우저로 접속하셔도 됩니다 (여기서 vm001 은 개인 클라우드 컴퓨터의 호스트 이름이므로 각자의 호스트 이름으로 접근하셔야 합니다)
<br>


#### 2-2-3. `top` : 컨테이너에 떠 있는 프로세스를 확인합니다

* 실행 확인 후 종료합니다
```bash
# docker top <container_name> <ps options>
docker top nginx
docker rm -f nginx
```
<br>


### 2-3. 컨테이너 상호작용

#### 2-3-1. 실습을 위한 우분투 컨테이너를 기동합니다

```bash
docker run --rm --name ubuntu20 -dit ubuntu:20.04
```

#### 2-3-1. `cp` :  호스트에서 컨테이너로 혹은 반대로 파일을 복사합니다

```bash
# docker cp <container_name>:<path> <host_path> and vice-versa
docker cp ./helloworld.sh ubuntu20:/tmp
```
<br>

#### 2-3-3. `exec` : 컨테이너 내부에 명령을 실행합니다 
```bash
# docker exec <container_name> <args>
docker exec ubuntu20 /tmp/helloworld.sh
```
<br>

#### 2-3-4. 사용한 모든 컨테이너를 종료합니다

* 직접 도커로 실행한 작업은 도커 명령을 이용해 종료합니다
```bash
docker rm -f `docker ps -a | grep -v CONTAINER | awk '{ print $1 }'`
```

<details><summary> :blue_book: 1. [중급] `nginx` 컨테이너를 시작 후에 프로세스 확인 및 로그를 출력하고 종료하세요 </summary>


> 출력 결과가 오류가 발생하지 않고, 아래와 유사하다면 성공입니다

```text
docker run --name nginx -dit nginx:latest
docker ps
docker top nginx
docker logs nginx
docker stop nginx
docker rm nginx
```

</details>
<br>

[목차로 돌아가기](#1일차-데이터-엔지니어링-고급)

<br>



### Docker 고급 명령어

### 2-4. 컨테이너 이미지 생성관리

#### 2-4-1. `images` : 현재 로컬에 저장된 이미지 목록을 출력합니다 
```bash
docker images
```
<br>


#### 2-4-2. `commit` : 현재 컨테이너를 별도의 이미지로 저장합니다 

```bash
# 실습을 위해 우분투 컨테이너를 생성합니다
docker run --rm --name ubuntu -dit ubuntu:18.04
```

```bash
# helloworld.sh 스크립트를 컨테이너 내부에 복사합니다
docker cp ./helloworld.sh ubuntu:/tmp
```

```bash
# docker commit <container_name> <repository>:<tag>
# 현재 helloworld.sh 가 복사된 컨테이너를 ubuntu:hello 로 저장해봅니다
docker commit ubuntu ubuntu:hello
```
<br>


#### 2-4-3. `rmi` : 해당 이미지를 삭제합니다

```bash
# 이전에 `ubuntu:18.04` 기반의 컨테이너를 종료하고, 이미지도 삭제합니다
docker rm -f ubuntu
docker rmi ubuntu:18.04
```

```bash
# ubuntu:hello 가 남아있는지 확인합니다
docker image ls | grep ubuntu | grep hello
```
<br>

<details><summary> :green_book: 2. [기본] ubuntu:hello 이미지를 이용하여 helloworld.sh 을 실행하세요</summary>


> 출력 결과가 오류가 발생하지 않고, 아래와 유사하다면 성공입니다

```bash
docker run --rm ubuntu:hello /tmp/helloworld.sh
# hello world
```

</details>
<br>


### 2-5. 컨테이너 이미지 전송관리

> 본 명령은 dockerhub.com 과 같은 docker registry 계정이 있어야 실습이 가능하므로 실습에서는 제외합니다

#### 2-5-1. `pull` : 대상 이미지를 레포지토리에서 로컬로 다운로드합니다
```bash
# docker pull repository[:tag]
docker pull psyoblade/data-engineer-ubuntu:18.04
```

#### 2-5-2. `push` : 대상 이미지를 레포지토리로 업로드합니다
> push 명령은 계정 연동이 되어 있지 않으므로 현재는 동작하지 않습니다
```bash
# docker push repository[:tag]
# docker push psyoblade/data-engineer-ubuntu:18.04
# errors:
# denied: requested access to the resource is denied
# unauthorized: authentication required
```

#### 2-5-3. `login` : 레지스트리에 로그인 합니다
> login 명령은 계정 연동이 되어 있지 않으므로 현재는 동작하지 않습니다
```bash
# terminal
# docker login
```

#### 2-5-4. `logout` : 레지스트리에 로그아웃 합니다
> logout 명령은 계정 연동이 되어 있지 않으므로 현재는 동작하지 않습니다
```bash
# docker logout
```
<br>


### 2-6. 컨테이너 이미지 빌드

> 별도의 Dockerfile 을 생성하고 해당 이미지를 바탕으로 새로운 이미지를 생성할 수 있습니다

#### 2-6-1. `Dockerfile` 생성

* `Ubuntu:18.04` LTS 이미지를 한 번 빌드하기로 합니다
  - <kbd>FROM image:tag</kbd> : 기반이 되는 이미지와 태그를 명시합니다
  - <kbd>MAINTAINER email</kbd> : 컨테이너 이미지 관리자
  - <kbd>COPY path dst</kbd> : 호스트의 `path` 를 게스트의 `dst`로 복사합니다
  - <kbd>ADD src dst</kbd> : COPY 와 동일하지만 추가 기능 (untar archives 기능, http url 지원)이 있습니다
  - <kbd>RUN args</kbd> : 임의의 명령어를 수행합니다
  - <kbd>USER name</kbd> : 기본 이용자를 지정합니다 (ex_ root, ubuntu)
  - <kbd>WORKDIR path</kbd> : 워킹 디렉토리를 지정합니다
  - <kbd>ENTRYPOINT args</kbd> : 메인 프로그램을 지정합니다
  - <kbd>CMD args</kbd> : 메인 프로그램의 파라메터를 지정합니다
  - <kbd>ENV name value</kbd> : 환경변수를 지정합니다

* 아래와 같이 터미널에서 입력하고
```bash
cat > Dockerfile
```

* 아래의 내용을 복사해서 붙여넣고, 엔터를 친 다음, <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 명령으로 나오면 파일이 생성됩니다
```bash
FROM ubuntu:18.04
LABEL maintainer="student@modulabs.com"

RUN apt-get update && apt-get install -y rsync tree

EXPOSE 22 873
CMD ["/bin/bash"]
```

* [`ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint)와 `CMD`의 차이점 비교

```bash
FROM ubuntu:18.04
LABEL maintainer="student@modulabs.com"

RUN apt-get update && apt-get install -y rsync tree

EXPOSE 22 873

# 정상적으로 프로그램을 기동하고 - 옵션을 CMD
# ENTRYPOINT ["/bin/echo"]
# CMD ["hello"]

# 정상적인 프로그램 기동 시에 필수 옵션을 넣고, 옵셔널 옵션을 CMD
# ENTRYPOINT ["/bin/echo", "mandatory-options"]
# CMD ["lg"]

# 기본 우분투 서버기동 아무런 엔트리가 없음
# ENTRYPOINT []
# CMD []

# 커맨드는 의미가 없음 entrypoint 가 없고, 커맨드는 덮어쓰여지므로
# ENTRYPOINT []
# CMD ["/bin/echo"]
```

>  `docker build -t ubuntu:local . ; docker run --rm -it ubuntu:local` 통해서 설정 변경 후 테스트

#### 2-6-2. 이미지 빌드

> 위의 이미지를 통해서 베이스라인 우분투 이미지에 rsync 와 tree 가 설치된 새로운 이미지를 생성할 수 있습니다

* 도커 이미지를 빌드합니다
  - <kbd>-f, --file</kbd> : default 는 현재 경로의 Dockerfile 을 이용하지만 별도로 지정할 수 있습니다
  - <kbd>-t, --tag</kbd> : 도커 이미지의 이름과 태그를 지정합니다
  - <kbd>-q, --quiet</kbd> : 빌드 로그의 출력을 하지 않습니다
  - <kbd>.</kbd> : 현재 경로에서 빌드를 합니다 

```bash
# terminal
docker build -t ubuntu:local .
```

<details><summary> :green_book: 3. [기본] 도커 이미지를 빌드하고 `echo 'hello world'`를 출력해 보세요</summary>


> 출력 결과가 오류가 발생하지 않고, 아래와 유사하다면 성공입니다

```bash
Sending build context to Docker daemon  202.8kB
Step 1/5 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
e7ae86ffe2df: Pull complete
Digest: sha256:3b8692dc4474d4f6043fae285676699361792ce1828e22b1b57367b5c05457e3
Status: Downloaded newer image for ubuntu:18.04
...
Step 5/5 : CMD ["/bin/bash"]
 ---> Running in 88f12333612b
Removing intermediate container 88f12333612b
 ---> da9a0e997fc0
Successfully built da9a0e997fc0
Successfully tagged ubuntu:local
```

> 아래와 같이 출력합니다
```bash
docker run --rm -it ubuntu:local echo 'hello world'
```

</details>
<br>


### 2-7. 도커 이미지 이해하기

> 도커 컨테이너 이미지들의 다른점을 이해하고 다양한 실습을 통해 깊이 이해합니다


### 2-7-1. 도커 이미지 크기 비교

* 알파인 리눅스 vs. 우분투 컨테이너 이미지 크기 비교
```bash
docker pull alpine
docker pull ubuntu
docker image ls
```
<br>


### 2-7-2. 알파인 리눅스 명령어 실습

* 알파인 리눅스 환경이 아니지만 해당 리눅스 처럼 실행해보기
```bash
docker run alpine top
```
> top 명령어는 <kbd><samp>Ctrl</samp>+<samp>C</samp></kbd> 명령으로 종료합니다
<br>


* 기타 명령어도 테스트 합니다
```bash
docker run alpine uname -a
docker run alpine cat /etc/issue
```
<br>

<details><summary> :blue_book: 4. [중급] 위 명령어 실행으로 생성된 컨테이너는 어떻게 삭제할까요?</summary>


* 전체 컨테이너 목록(-a 옵션으로 중지된 컨테이너까지 확인) 가운데 alpine 을 포함한 목록의 컨테이너 아이디를 찾아 모두 종료합니다
```bash
docker rm -f `docker ps -a | grep alpine | awk '{ print $1 }'`
```

* 사용하지 않는 컨테이너 정리 명령어 (-f, --force)
```bash
docker container prune -f
```

</details>
<br>


### 2-7-3. 알파인 리눅스에서 패키지 설치

> 리눅스 배포판마다 패키지 관리자가 다르기 때문에 참고로 실습합니다


* bash 가 없기 때문에 /bin/sh 을 통해 --interactive --tty 를 생성해봅니다
```bash
docker run --rm -it alpine /bin/sh
```
> `--rm` 명령으로 가비지 컨테이너가 생성되지 않도록 하는 것도 좋습니다
<br>

* vim 도 없기 때문에 패키지 도구인 apk 및 apk add/del 를 통해 vim 을 설치 및 제거합니다
  - apk { add, del, search, info, update, upgrade } 등의 명령어를 사용할 수 있습니다

* 업데이트 및 vim 설치
```bash
apk update
apk add vim
```

* 설치된 패키지 제거
```bash
apk del vim
```
<kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 명령으로 터미널에서 빠져나올 수 있습니다
<br>
<br>



### 2-7-4. [메모리 설정을 변경한 상태 확인](https://docs.docker.com/config/containers/start-containers-automatically)

* 컨테이너의 리소스를 제한하는 것도 가능합니다
  - 기본적으로 도커 기동 시에 로컬 도커가 사용할 수 있는 리소스의 최대치를 사용할 수 있습니다
  - 이번 예제에서는 도커를 실행하고 상태를 확인하기 위해 백그라운드 실행(-dit)을 합니다
```bash
docker run --name ubuntu_500m -dit -m 500m ubuntu
```

* 메모리 제약을 두고 띄운 컨테이너의 상태를 확인합니다
```bash
docker ps -f name=ubuntu_500m
```

* 메모리 제약을 두고 띄운 컨테이너의 상태를 확인합니다
```bash
docker stats ubuntu_500m
```
> <kbd><samp>Ctrl</samp>+<samp>C</samp></kbd> 명령으로 종료합니다

<details><summary> :blue_book: 5. [중급] 메모리 제약을 주지 않은 컨테이너`ubuntu_unlimited`를 기동하고 컨테이너 상태를 확인해 보세요</summary>


> 출력 결과가 오류가 발생하지 않고, 아래와 유사하다면 성공입니다

* 컨테이너를 기동하고
```bash
docker run --name ubuntu_unlimited -dit ubuntu
```

* 상태를 확인합니다
```bash
docker stats `docker ps | grep ubuntu_unlimited | awk '{ print $1 }'`
```

</details>

<details><summary> :blue_book: 6. [중급] 바로 위의 실습 정답을 활용해서 ubuntu 문자열이 포함된 모든 컨테이너를 종료해 보세요</summary>


> 출력 결과가 오류가 발생하지 않고, 아래와 유사하다면 성공입니다

```bash
docker rm -f `docker ps | grep ubuntu | awk '{ print $1 }'`
```

</details>
<br>


### 2-8. MySQL 로컬 장비에 설치하지 않고 사용하기

> 호스트 장비에 MySQL 설치하지 않고 사용해보기


#### 2-8-1. [MySQL 데이터베이스 기동](https://hub.docker.com/_/mysql)

* 아래와 같이 도커 명령어를 통해 MySQL 서버를 기동합니다
```bash
docker run --name mysql-volatile \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  -d mysql
```
<br>

* 서버가 기동되면 해당 서버로 접속합니다
  - 너무 빨리 접속하면 서버가 기동되기전이라 접속이 실패할 수 있습니다
```bash
sleep 10
docker exec -it mysql-volatile mysql -uuser -ppass
```

#### 2-8-2. 테스트용 테이블을 생성해봅니다

```sql
# mysql>
use testdb;
create table foo (id int, name varchar(300));
insert into foo values (1, 'my name');
select * from foo;
```
> <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 명령으로 빠져나옵니다


#### 2-8-3. 컨테이너를 강제로 종료합니다

```bash
docker rm -f mysql-volatile
docker volume ls
```

<details><summary> :blue_book: 7. [중급] mysql-volatile 컨테이너를 다시 생성하고 테이블을 확인해 보세요</summary>


> 테이블이 존재하지 않는다면 정답입니다.

* 볼륨을 마운트하지 않은 상태에서 생성된 MySQL 데이터베이스는 컨테이너의 임시 볼륨 저장소에 저장되므로, 컨테이너가 종료되면 더이상 사용할 수 없습니다
  - 사용한 컨테이너는 삭제 후 다시 생성하여 테이블이 존재하는지 확인합니다
```bash
docker rm -f mysql-volatile
```

</details>
<br>


### 2-9. 볼륨 마운트 통한 MySQL 서버 기동하기

> 이번에는 별도의 볼륨을 생성하여, 컨테이너가 예기치 않게 종료되었다가 다시 생성되더라도, 데이터를 보존할 수 있게 볼륨을 생성합니다. 


#### 2-9-1. 볼륨 마운트 생성

* 아래와 같이 볼륨의 이름만 명시하여 마운트하는 것을 [Volume Mount](https://docs.docker.com/storage/volumes/) 방식이라고 합니다
  - `docker volume ls` 명령을 통해 생성된 볼륨을 확인할 수 있습니다
  - 이렇게 생성된 별도의 격리된 볼륨으로 관리되며 컨테이너가 종료되더라도 유지됩니다
```bash
docker run --name mysql-persist \
  -p 3307:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  -v mysql-volume:/var/lib/mysql \
  -d mysql

sleep 10
docker exec -it mysql-persist mysql --port=3307 -uuser -ppass
```

#### 2-9-2. 볼륨 확인 실습

<details><summary> :closed_book: 8. [고급] mysql-persist 컨테이너를 강제 종료하고, 동일한 설정으로 다시 생성하여 테이블이 존재하는지 확인해 보세요</summary>


> 테이블이 존재하고 데이터가 있다면 정답입니다

```sql
# mysql>
use testdb;
create table foo (id int, name varchar(300));
insert into foo values (1, 'my name');
select * from foo;
```

```bash
# terminal : 컨테이너를 삭제합니다
docker rm -f mysql-persist

# 볼륨이 존재하는지 확인합니다
docker volume ls
```

```bash
# terminal : 새로이 컨테이너를 생성하고 볼륨은 그대로 연결합니다
docker run --name mysql-persist \
  -p 3307:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  -v mysql-volume:/var/lib/mysql \
  -d mysql

sleep 10
docker exec -it mysql-persist mysql --port=3307 -uuser -ppass
```

* 컨테이너와 무관하게 데이터가 존재하는지 확인합니다
```sql
# mysql>
use testdb;
select * from foo;
```

</details>
<br>


### 2-10. 바인드 마운트 통한 MySQL 서버 기동하기

#### 2-10-1. 바인드 마운트를 추가하여 저장소 관리하기 

> 이번에는 호스트 장비의 경로에 직접 저장하는 바인드 마운트에 대해 실습합니다

* 아래와 같이 상대 혹은 절대 경로를 포함한 볼륨의 이름을 명시하여 마운트하는 것을 [Bind Mount](https://docs.docker.com/storage/bind-mounts/) 방식이라고 합니다
  - 호스트의 특정 경로를 저장소로 사용하게 되어, 호스트에서 직접 접근 및 확인이 가능합니다
```bash
# terminal : 절대경로를 위해 `pwd` 명령을 사용합니다
docker run --name mysql-bind \
  -p 3308:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  -v `pwd`/mysql/bind:/var/lib/mysql \
  -d mysql

sleep 10
docker exec -it mysql-bind mysql --port=3308 -uuser -ppass
```

> 이번 예제는 경로만 다를 뿐 동일하므로 실습은 각자 해보시기 바랍니다
<br>

#### 2-10-2. 실습이 끝나면, 모든 컨테이너는 *반드시 종료해 주세요*

> 다음 실습 시에 포트가 충돌하거나 컨테이너 이름이 충돌하는 경우 기동에 실패할 수 있습니다
```bash
docker rm -f `docker ps -aq`
```

<br>

### 2-11 기타 예외적인 상황

>  경우에 따라서 포트가 충돌이 나서 실행이 되지 않는 경우가 있으므로 이전에 구성되어 있는 서버나 호스트 장비에 이미 서비스 되고 있는 포트를 확인해보면 좋습니다

```bash
netstat -a | grep LISTEN | grep -V LISTENING
```

* 위의 결과에서 보여주는 모든 `LISTEN` 포트는 사용 중이므로 주의가 필요합니다.

```python
# 파이썬 버전 별 심플 웹서버
python -m SimpleHTTPServer 8080
python3 -m http.server 8080
```

* 기존 서버를 종료하거나, 현재 컨테이너의 포트를 변경하는 방법이 있습니다

[목차로 돌아가기](#1일차-데이터-엔지니어링-고급)

<br>



## 3. Docker Compose 명령어 실습

> 도커 컴포즈는 **도커의 명령어들을 반복적으로 수행되지 않도록 yml 파일로 저장해두고 활용**하기 위해 구성되었고, *여러개의 컴포넌트를 동시에 기동하여, 하나의 네트워크에서 동작하도록 구성*한 것이 특징입니다. 내부 서비스들 간에는 컨테이너 이름으로 통신할 수 있어 테스트 환경을 구성하기에 용이합니다. 
<br>

### 실습을 위한 기본 환경을 가져옵니다

```bash
# terminal
cd ~/work
git clone https://github.com/psyoblade/data-engineer-advanced-training.git
cd ~/work/data-engineer-advanced-training/day1
```
<br>


### Docker Compose 기본 명령어

### 3-1. 컨테이너 관리

> 도커 컴포즈는 **컨테이너를 기동하고 작업의 실행, 종료 등의 명령어**를 주로 다룬다는 것을 알 수 있습니다. 아래에 명시한 커맨드 외에도 도커 수준의 명령어들(pull, create, start, stop, rm)이 존재하지만 잘 사용되지 않으며 일부 deprecated 되어 자주 사용하는 명령어 들로만 소개해 드립니다

* [The Compose Specification](https://github.com/psyoblade/compose-spec/blob/master/spec.md)
* [Deployment Support](https://github.com/psyoblade/compose-spec/blob/master/deploy.md)

```bash
# .bashrc 혹은 .zshrc 파일에 추가하고 source ~/.bashrc 로 등록합니다
# 또는 직접 터미널에서 아래의 명령어를 실행하셔도 됩니다

alias d="docker-compose"
```

> 자주 사용하는 명령어 `docker-compose`를 리눅스 `alias` 명령을 이용하여 등록합니다 

<br>

#### 3-1-1. up : `docker-compose.yml` 파일을 이용하여 컨테이너를 이미지 다운로드(pull), 생성(create) 및 시작(start) 시킵니다
  - <kbd>-f [filename]</kbd> : 별도 yml 파일을 통해 기동시킵니다 (default: `-f docker-compose.yml`)
  - <kbd>-d, --detach <filename></kbd> : 서비스들을 백그라운드 모드에서 수행합니다
  - <kbd>-e, --env `KEY=VAL`</kbd> : 환경변수를 전달합니다
  - <kbd>--scale [service]=[num]</kbd> : 특정 서비스를 복제하여 기동합니다 (`container_name` 충돌나지 않도록 주의)
```bash
# docker-compose up <options> <services>
docker-compose up -d
```
<br>

#### 3-1-2. down : 컨테이너를 종료 시킵니다
  - <kbd>-t, --timeout [int] <filename></kbd> : 셧다운 타임아웃을 지정하여 무한정 대기(SIGTERM)하지 않고 종료(SIGKILL)합니다 (default: 10초)
```bash
# docker-compose down <options> <services>
docker-compose down
```
<br>

<details><summary> :closed_book: 9. [고급] 컴포즈 명령어(--scale)를 이용하여 우분투 컨테이너를 3개 띄워보세요  </summary>


> 아래와 유사하게 작성 및 실행했다면 정답입니다


* `docker-compose` 명령어 예제입니다 
  - 컴포즈 파일에 `container_name` 이 있으면 이름이 충돌나기 때문에 별도의 파일을 만듭니다
```bash
# terminal
cat docker-compose.yml | grep -v 'container_name: ubuntu' > ubuntu-no-container-name.yml
docker-compose -f ubuntu-no-container-name.yml up --scale ubuntu=2 -d ubuntu
docker-compose -f ubuntu-no-container-name.yml down
```

* `ubuntu-scale.yml` 예제입니다 
  - 우분투 이미지를 기본 이미지를 사용해도 무관합니다
```bash
# cat > ubuntu-replicated.yml
version: "3"

services:
  ubuntu:
    image: psyoblade/data-engineer-ubuntu:20.04
    restart: always
    tty: true
		deploy:
      mode: replicated
      replicas: 3
      endpoint_mode: vip

networks:
  default:
```

* 아래와 같이 기동/종료 합니다
```bash
docker-compose -f ubuntu-replicated.yml up -d ubuntu
docker-compose -f ubuntu-replicated.yml down
```

</details>
<br>


### 3-2. 기타 자주 사용되는 명령어

#### 3-2-1. exec : 컨테이너에 커맨드를 실행합니다
  - <kbd>-d, --detach</kbd> : 백그라운드 모드에서 실행합니다
  - <kbd>-e, --env `KEY=VAL`</kbd> : 환경변수를 전달합니다
  - <kbd>-u, --user [string]</kbd> : 이용자를 지정합니다
  - <kbd>-w, --workdir [string]</kbd> : 워킹 디렉토리를 지정합니다
```bash
# docker-compose exec [options] [-e KEY=VAL...] [--] SERVICE COMMAND [ARGS...]
docker-compose up -d
docker-compose exec ubuntu echo hello world
```
<br>

#### 3-2-2. logs : 컨테이너의 로그를 출력합니다
  - <kbd>-f, --follow</kbd> : 출력로그를 이어서 tailing 합니다
```bash
# terminal
docker-compose logs -f ubuntu
```
<br>

#### 3-2-3. pull : 컨테이너의 모든 이미지를 다운로드 받습니다
  - <kbd>-q, --quiet</kbd> : 다운로드 메시지를 출력하지 않습니다 
```bash
# terminal
docker-compose pull
```
<br>

#### 3-2-4. ps : 컨테이너 들의 상태를 확인합니다
  - <kbd>-a, --all</kbd> : 모든 서비스의 프로세스를 확인합니다
```bash
# terminal
docker-compose ps -a
```
<br>

#### 3-2-5. top : 컨테이너 내부에 실행되고 있는 프로세스를 출력합니다
```bash
# docker-compose top <services>
docker-compose top mysql
docker-compose top ubuntu
```

#### 3-2-6. 사용한 모든 컨테이너를 종료합니다

* 컴포즈를 통해 실행한 작업은 컴포즈를 이용해 종료합니다
```bash
docker-compose down
```

[목차로 돌아가기](#1일차-데이터-엔지니어링-고급)

<br>


### Docker Compose 고급 명령어

>  도커 컴포즈 파일을 이용하여, MySQL 기본 설정`my.conf` 파일을 커스터마이징 하고, 임의의 데이터를  `init.sql`파일을 통해서 초기화 할 수 있습니다

### 3-3. 컴포즈 파일을 통한 실습

#### 3-3-1. 도커 컴포즈를 통해서 커맨드라인 옵션을 설정을 통해 수행할 수 있습니다

```bash
# mysql: 이 등장하는 이후로 20줄을 출력
cat docker-compose.yml | grep -ia20 'mysql:' docker-compose.yml
```
```yaml
# docker-compose.yml
  mysql:
    container_name: mysql
    image: psyoblade/data-engineer-mysql:1.1
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: testdb
      MYSQL_USER: sqoop
      MYSQL_PASSWORD: sqoop
    ports:
      - '3306:3306'
    networks:
      - default
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      interval: 3s
      timeout: 1s
      retries: 3
    volumes:
      - ./mysql/etc:/etc/mysql/conf.d
```
<br>


#### 3-3-2. 도커 컴포즈 파일(`docker-compose.yml`)을 직접 생성 합니다

> 컴포즈 실습을 위한 경로를 생성합니다

```bash
# terminal
mkdir -p ~/work/compose-training
cd ~/work/compose-training
```
* `custom`, `init` 2개의 경로를 생성합니다
```bash
for dir in `echo "custom init"`; do mkdir -p $dir; done
```
<br>

### 3-4. 외부 볼륨을 통한 환경설정

> 외부 볼륨을 통한 환경설정 제공 및 설정을 실습합니다

#### 3-4-1. 캐릭터셋 변경 위한 `my.cnf` 생성하기

```bash
# cat > custom/my.cnf
[client]
default-character-set=utf8

[mysqld]
character-set-client-handshake=FALSE
init_connect="SET collation_connection = utf8_general_ci"
init_connect="SET NAMES utf8"
character-set-server=utf8
collation-server=utf8_general_ci

[mysql]
default-character-set=utf8
```
<br>


#### 3-4-2. MySQL 기동을 위한 `docker-compose.yml` 파일 생성

> 지정한 설정파일을 사용하고, 내부 볼륨을 통한 MySQL 기동으로 변경합니다

```bash
# cat > docker-compose.yml
version: "3"

services:
  mysql:
    container_name: mysql
    image: local/mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: testdb
      MYSQL_USER: user
      MYSQL_PASSWORD: pass
    volumes:
      - ./custom:/etc/mysql/conf.d

networks:
  default:
    name: default_network
```
<br>


### 3-5. 초기화 파일을 적용한 MySQL 도커 이미지 생성

#### 3-5-1. MySQL 초기화 데이터 파일 `testb.sql` 파일을 생성합니다

```bash
# cat > init/testdb.sql
DROP TABLE IF EXISTS `seoul_popular_trip`;
CREATE TABLE `seoul_popular_trip` (
  `category` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `naddress` varchar(100) DEFAULT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `tag` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
LOCK TABLES `seoul_popular_trip` WRITE;
INSERT INTO `seoul_popular_trip` VALUES (0,25931,'통인가게 ','110-300 서울 종로구 관훈동 16 ','03148 서울 종로구 인사동길 32 (관훈동) ','02-733-4867','오래된가게,고미술,통인정신,통인가게,공예샵,현대공예');
UNLOCK TABLES;
```
<br>


#### 3-5-2. 커스텀 MySQL 빌드를 위한 도커파일 `Dockerfile`을 생성합니다

```Dockerfile
# cat > Dockerfile
ARG BASE_CONTAINER=mysql:5.7
FROM $BASE_CONTAINER
LABEL maintainer="student@modulabs.com"

ADD ./init /docker-entrypoint-initdb.d

EXPOSE 3306

CMD ["mysqld"]
```
<br>


#### 3-5-3. 로컬에서 도커 이미지를 빌드합니다

```bash
docker build -t local/mysql:5.7 .
```
<br>


#### 3-5-4. 빌드된 이미지로 다시 테스트

* 직접 작성한 `docker-compose.yml` 파일로 컨테이너를 기동합니다
```bash
docker-compose up -d
```
* MySQL 서버에 접속합니다
```bash
sleep 10
docker-compose exec mysql mysql -uuser -ppass
```
```sql
use testdb;
select * from seoul_popular_trip;
```
<br>


### 3-6. 도커 컴포즈 통한 여러 이미지 실행

> MySQL 과 phpMyAdmin 2가지 서비스를 기동하는 컴포즈를 생성합니다

* 기존의 컨테이너를 중단시킵니다 (삭제가 아닙니다)
```bash
# terminal
docker-compose down
```

#### 3-6-1. 도커 컴포즈를 통해 phpMyAdmin 추가 설치

* 기존의 컨테이너를 삭제하게 되면 볼륨 마운트가 없기 때문에 데이터를 확인할 수 없는 점 유의하시기 바랍니다
  - 아래는 기존의  `docker-compose.yml` 파일을 덮어쓰되 phpMyAdmin 만 추가합니다
```bash
# cat > docker-compose.yml
version: "3"

services:
  mysql:
    image: local/mysql:5.7
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: testdb
      MYSQL_USER: user
      MYSQL_PASSWORD: pass
    volumes:
      - ./custom:/etc/mysql/conf.d
  php:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    links:
      - mysql
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_ARBITRARY: 1
    restart: always
    ports:
      - 80:80
      
networks:
  default:
    name: default_network
```

```bash
# 변경한 컴포즈를 실행합니다
docker-compose up -d
```

> phpMyAdmin(http://`vm{###}.koreacentral.cloudapp.azure.com`) 사이트에 접속하여 서버: `mysql`, 사용자명: `user`, 암호: `pass` 로 접속합니다

<br>

### 3-7. MySQL 이 정상적으로 로딩된 이후에 접속하도록 설정합니다

> 테스트 헬스체크를 통해 MySQL 이 정상 기동되었을 때에 다른 어플리케이션을 띄웁니다

* 기존의 컨테이너를 중단시킵니다 (삭제가 아닙니다)
```bash
# terminal
docker-compose down
```

#### 3-7-1. MySQL 기동이 완료되기를 기다리는 컴포즈 파일을 구성합니다

* 아래와 같이 구성된 컴포즈 파일을 생성합니다
```bash
# cat docker-compose.yml
version: "3"

services:
  mysql:
    image: local/mysql:5.7
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: testdb
      MYSQL_USER: user
      MYSQL_PASSWORD: pass
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      interval: 3s
      timeout: 1s
      retries: 3
    volumes:
      - ./custom:/etc/mysql/conf.d
  php:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    depends_on:
      - mysql
    links:
      - mysql
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_ARBITRARY: 1
    restart: always
    ports:
      - 80:80
```

#### 3-7-2. 실습이 완료되었으므로 모든 컨테이너를 종료합니다
```bash
# terminal
docker-compose down
```

[목차로 돌아가기](#1일차-데이터-엔지니어링-고급)

<br>


## 4. 참고 자료
* [Docker Cheatsheet](https://dockerlabs.collabnix.com/docker/cheatsheet/)
* [Docker Compose Cheatsheet](https://devhints.io/docker-compose)
* [Compose Cheatsheet](https://buildvirtual.net/docker-compose-cheat-sheet/)
* [Install Docker Desktop on Windows](https://docs.docker.com/desktop/windows/install/)
* [Docker Container Memory Limits](https://www.joinc.co.kr/w/man/12/docker/limits#s-4.)
> ***Docker Desktop 약관 업데이트*** : 대규모 조직(직원 250명 이상 또는 연간 매출 1천만 달러 이상)에서 Docker Desktop을 전문적으로 사용하려면 유료 Docker 구독이 필요합니다. 본 약관의 발효일은 2021년 8월 31일이지만 유료 구독이 필요한 경우 2022년 1월 31일까지 유예 기간이 있습니다. 자세한 내용은 블로그 Docker is Updating and Extending Our Product Subscriptions 및 Docker Desktop License Agreement를 참조하십시오.
* [Docker is Updating and Extending Our Product Subscariptions](https://www.docker.com/blog/updating-product-subscriptions/)

