#!/bin/bash

set -x

echo 'deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/azurecore/ trusty main' | tee -a /etc/apt/sources.list.d/azure.list
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
apt-get install apt-transport-https
apt-get update
apt-get install -y azure-security azsec-mdsd azsec-monitor azsec-clamav
apt-get install azure-cli

config-mdsd syslog -e rsyslog

ZIP_FILE=""


# retrieve and parse extension parameters
if [[ -n "$1" ]]; then
    IFS=';' read -ra INPUT <<< "$1"
    if [[ -n "${INPUT[0]}" ]]; then
        ZIP_FILE="${INPUT[0]}"  
    fi
    # if [[ -n "${INPUT[1]}" ]]; then
    #     SERVICE_PRINCIPAL_KEY="${INPUT[1]}"
    # fi
    # if [[ -n "${INPUT[2]}" ]]; then
    #     TENANT="${INPUT[2]}"
    # fi
fi

if [[ -z $ZIP_FILE ]]; then
    exit 1
fi

mkdir /etc/mdsd.d

echo $ZIP_FILE | base64 --decode > /etc/mdsd.d/file.tar.gz
tar -zxvf /etc/mdsd.d/file.tar.gz
rm /etc/mdsd.d/file.tar.gz

chown syslog /etc/mdsd.d/gcskey.pem
chmod 400 /etc/mdsd.d/gcskey.pem

azsecd config -s baseline -d P1D 
azsecd config -s software -d P1D 
azsecd config -s clamav -d P1D 

service mdsd restart 
service azsecd restart
