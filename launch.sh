#!/bin/bash

rm -rf *.csv

LOGS_DIR=Logs
mkdir -p $LOGS_DIR

export PAGES=`ruby pageNumGetter.rb`
PAGE_NUMBER=0

while [[ $PAGE_NUMBER -lt $PAGES ]]; do
	nohup ruby scanner.rb $PAGE_NUMBER > "$LOGS_DIR/$PAGE_NUMBER.log" 2>&1 &
	PAGE_NUMBER=$[$PAGE_NUMBER+1]
done