# 데이터 엔지니어링 고급 실습

> 데이터 엔지니어링 고급 과정 실습을 위한 페이지 입니다.

## [1일차. 컨테이너 기술의 이해](https://github.com/psyoblade/data-engineer-advanced-training/tree/master/day1/README.md)

## [2일차. 스트림 데이터 수집](https://github.com/psyoblade/data-engineer-advanced-training/tree/master/day2/README.md)

## [3일차. 스파크 배치 성능 튜닝](https://github.com/psyoblade/data-engineer-advanced-training/tree/master/day3/README.md)

## [4일차. 스파크 스트리밍 처리](https://github.com/psyoblade/data-engineer-advanced-training/tree/master/day4/README.md)

## [5일차. 스트리밍 파이프라인 설계](https://github.com/psyoblade/data-engineer-advanced-training/tree/master/day5/README.md)



>  자주 사용하는 `.bashrc` 설정입니다

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

