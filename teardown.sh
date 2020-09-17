#!/bin/bash

argo delete --all
helm delete hlf-kube
helm delete hlf-orderer
helm delete hlf-frontend

kubectl wait --for=delete pods --all