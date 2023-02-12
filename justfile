# starts the dev cluster
start:
  ./bootstrap/start.sh

# starts the tunnel to the dev cluster. might require elevated privileges
route:
  minikube tunnel

# performs a cleanup actions
clean:
  cd bootstrap && terraform destroy -auto-approve
  minikube delete
  rm -rf ./bootstrap/*.pem
  rm -rf ./bootstrap/terraform.tfstate*
  rm -rf ./bootstrap/.terraform