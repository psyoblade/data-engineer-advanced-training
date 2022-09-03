#!/bin/bash
curl -i -X POST -d '{"column1":1,"column2":"float-type","logtime":1662130800.154709804}' http://localhost:8080/test
curl -i -X POST -d '{"column1":1,"column2":"unixtime-type","logtime":1662130800}' http://localhost:8081/test
curl -i -X POST -d '{"column1":1,"column2":"string-type","logtime":"2022-09-03 00:00:00 +0000"}' http://localhost:8082/test
curl -i -X POST -d '{"column1":1,"column2":"string-type","logtime":"2022-09-03 00:00:00 +0900"}' http://localhost:8082/test
