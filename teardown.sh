#!/bin/bash

argo delete --all
helm delete hlf-kube

kubectl wait --for=delete pods --all