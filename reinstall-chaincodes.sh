#!/bin/bash

if [ "$#" -ne 1 ]; then
   echo "first arg should be a new chaincode version"
   exit 2
fi
if [ ! -d "../network-config" ]; then
   echo "no network-config or chaincode folder found, create at path specified or change the paths in this script"
   exit 2
fi

# exit when any command fails
set -e

cd ./fabric-kube/
project_folder=../../network-config/
chaincode_folder=../../chaincode/

./prepare_chaincodes.sh $project_folder $chaincode_folder

helm upgrade hlf-kube ./hlf-kube -f $project_folder/network.yaml -f $project_folder/crypto-config.yaml  

helm template chaincode-flow/ -f $project_folder/network.yaml -f $project_folder/crypto-config.yaml --set chaincode.version=$1 | argo submit - --watch

## TODO