#!/bin/bash

file=$1
name=$2
time1=$(grep 'ProgressMeter -' $file | awk '$7 == 300' | awk '{print $6}')
time2=$(grep 'ProgressMeter -' $file | awk '$7 == 800' | awk '{print $6}')
var1=$(grep 'ProgressMeter -' $file | awk '$7 == 300' | awk '{print $8}')
var2=$(grep 'ProgressMeter -' $file | awk '$7 == 800' | awk '{print $8}')
throughput=$(awk "BEGIN {print 500/($time2-$time1)}")
echo $name": "$throughput
