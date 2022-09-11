### druid bulk update - update entire time range at once
> 벌크 인서트 방식은 해당 intervals 기간 내의 모든 데이터를 delete & insert 방식으로 처리되며 해당 기간 내의 데이터만 입력됩니다
```bash
cd /apache-druid-0.16.1-incubating
bin/post-index-task --file quickstart/tutorial/wordcount-v1-index.json --url http://localhost:8081
bin/post-index-task --file quickstart/tutorial/wikipedia-index.json --url http://localhost:8081
```

### turnilo generate druid config
> 드루이드 색인이 추가 및 변경 이후에 설정파일을 생성하여 터닐로 볼륨에 덮어쓰고, 재시작하면 컬렉션이 확인 됩니다
```bash
docker-compose run turnilo turnilo --druid http://druid:8082 --print-config --with-comments > turnilo/config/new-config.yml
docker-compose restart turnilo
```
