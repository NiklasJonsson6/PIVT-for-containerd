#!/bin/bash

if [ "$#" -ne 0 ]; then
   echo "no args allowed"
   exit 2
fi
if [ ! -d "../network-config" ]; then
   echo "no network-config or chaincode folder found, create at path specified or change the paths in this script"
   exit 2
fi

# exit when any command fails
set -e

cd ./fabric-kube/
project_folder=../../bft-config/
chaincode_folder=../../chaincode/

#echo "-- creating necessary stuff --"
#./init.sh $project_folder $chaincode_folder
# In essence: 
# # cp -r $project_folder/crypto-config hlf-kube/
# # cp -r $project_folder/channel-artifacts hlf-kube/
# # cp -r $project_folder/configtx.yaml hlf-kube/
# # # prepare chaincodes
# # ./prepare_chaincodes.sh $project_folder $chaincode_folder

# TODO 
# Copy crypto-config/ (maybe create if it vibes with the genesis block, the config should not change except for orderernodes / clients) 
   # already done manually for now
# Copy channel-artifacts/ (containing genesis.block), place the block in orderingnode-material aswell (who caeres about duplicates)
# Copy contigtx.yaml
# Prepare chaincode
./prepare_chaincodes.sh $project_folder $chaincode_folder

# Launch nodes
# Launch frontend with attribute set for hostname

echo "-- Launch the Raft based Fabric network in broken state (only because of useActualDomains=true) --"
helm install hlf-kube ./hlf-kube -f $project_folder/network.yaml \
-f $project_folder/crypto-config.yaml \
--set orderer.cluster.enabled=true --set peer.launchPods=false --set orderer.launchPods=false
# orderer services
helm install hlf-orderer ./hlf-orderer -f $project_folder/network.yaml \
-f $project_folder/crypto-config.yaml \
--set orderer.launchPods=true

echo "-- collect the host aliases --"
./collect_host_aliases.sh $project_folder

echo "-- then update the network with host aliases --"
helm upgrade hlf-kube ./hlf-kube -f $project_folder/network.yaml -f $project_folder/crypto-config.yaml \
-f $project_folder/hostAliases.yaml 

echo "-- waiting for all pods to start --"
kubectl wait --for condition=ready pods --all
# start frontend
# Apply hostAliases to frontend as well

#echo "-- create the channel(s) --"
#helm template channel-flow/ -f $project_folder/network.yaml -f $project_folder/crypto-config.yaml -f $project_folder/hostAliases.yaml | argo submit - --watch

#echo "-- install chaincodes --"
#helm template chaincode-flow/ -f $project_folder/network.yaml -f $project_folder/crypto-config.yaml -f $project_folder/hostAliases.yaml | argo submit - --watch
