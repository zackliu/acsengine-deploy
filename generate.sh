#!/bin/bash

set -x

if [[ -z $1 || -z $2 ]]; then
    echo "need dir and json"
    exit 1
fi

tar -czvf temp.tar.gz $1
ENCODEDFILE=$(base64 temp.tar.gz | tr -d '\n')
ENV="DiagnosticsProd"
ACCOUNT="SignalRShoeboxTest"
REGION="eastus"


sed -i "s#\"extensionParameters\":.*#\"extensionParameters\": \"${ENCODEDFILE};${ENV};${ACCOUNT};${REGION}\",#g" $2
rm temp.tar.gz