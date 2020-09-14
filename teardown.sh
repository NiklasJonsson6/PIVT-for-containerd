#!/bin/bash

argo delete --all
helm delete hlf-kube
helm delete hlf-orderer

kubectl wait --for=delete pods --all