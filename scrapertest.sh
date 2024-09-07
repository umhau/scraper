#!/bin/bash

set -e
clear

{
    testpage=$(mktemp -d)
    echo 'testing' > $testpage/index.html
    cd $testpage
    python3 -m http.server 8000
} &

cleanup () {
    kill $webserverpid && echo "killed webserver"
    rm -rf $testpage
}

trap cleanup EXIT

sleep 1
webserverpid="$(ps aux | grep 'python3 -m http.server 8000' | xargs | cut -d ' ' -f 2)"
echo "webserver pid: $webserverpid"

{
    echo '/tmp/ http://0.0.0.0:8000/' > /var/lib/scraper/pool/1234
    sleep 10
    echo '/tmp/ http://0.0.0.0:8000/' > /var/lib/scraper/pool/12345
    sleep 10
    echo '/tmp/ http://0.0.0.0:8000/' > /var/lib/scraper/pool/123456
} &

scraper
