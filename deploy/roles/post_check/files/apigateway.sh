#!bin/bash

if [ -f ./fastUnit.log ]; then
rm fastUnit.log
fi
java -jar fitall.jar -case --project=. >& fastUnit.log
awk '/(ERROR  REQ|Total run:|PASS:|FAIL:|SKIP:)/{print $0}' fastUnit.log >&1