#!/bin/bash
docker run --rm --log-driver=fluentd --name 'quiz5-container' --log-opt tag=docker.{{.Name}} ubuntu echo '{"message":"send message with name"}'
