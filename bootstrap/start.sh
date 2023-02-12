#!/bin/bash

if ! command -v kubectl &> /dev/null
then
  echo "kubectl could not be found"
  exit 1
fi

if ! command -v minikube &> /dev/null
then
  echo "minikube could not be found"
  exit 1
fi

if ! command -v mkcert &> /dev/null
then
  echo "mkcert could not be found"
  exit 1
fi

if ! command -v terraform &> /dev/null
then
  echo "terraform could not be found"
  exit 1
fi

if [[ -z "${BASE}" ]]; then
  echo "project base is not configured. Run 'direnv allow' to configure it."
  exit 1
fi

cd $BASE/bootstrap
mkcert --install localhost
terraform init --upgrade
terraform apply -auto-approve