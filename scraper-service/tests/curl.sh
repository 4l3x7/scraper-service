#!/bin/bash
for i in {1..5}
do
   curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "http://www.ara.cat"}' \
    http://alex.local
done

for i in {1..3}
do
   curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "https://www.ara.cat"}' \
    http://alex.local
done


for i in {1..2}
do
   curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "https://www.google.com"}' \
    http://alex.local
done

for i in {1..8}
do
   curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "http://phaidra.ai"}' \
    http://alex.local
done

                                                                                          