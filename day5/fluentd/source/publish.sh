#!/bin/bash
# prompt yes 인 경우에 수행하며 실행 후에 sleep_secs 만큼 슬립
# 입력된 파일의 2번째 라인부터 (jump_line 수 만큼, loop_count 수 만큼 반복), 1개 파일 생성

if [[ $# -ne 1 ]]; then echo "illegal args --> ./$0 movies.tsv" ; exit 1 ; fi

input_filename=$1
if [[ ! -f $input_filename ]]; then echo "illegal filename --> not found $input_filename" ; exit 2 ; fi

work_dir="./movies"
from_line=2
jump_line=10
loop_count=100
sleep_secs=10

clear_work_dir() {
    echo "rm -r $work_dir; mkdir $work_dir"
    rm -r $work_dir; mkdir $work_dir
}

if [[ -d $work_dir ]]; then
    clear_work_dir
fi

prompt_ready() {
    while [[ $response != "yes" ]]; do
        echo "when ready type 'yes'"
        read response
    done
}

prompt_ready
for x in $(seq 1 $loop_count); do
    to_until=$(($x*$jump_line))
    to_line=$(($to_until-1))
    echo $from_line $to_line
    filename=`printf "movies_%03d_%03d.tsv" $from_line $to_line`
    sed -n ${from_line},${to_line}p $input_filename > $work_dir/$filename
    from_line=$to_until
    sleep $sleep_secs
done
