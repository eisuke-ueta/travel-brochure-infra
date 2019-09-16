# Travel Brochure Infra

## Tech Stack
- Frontend: Vue.js, Nuxt.js, Vuetifyjs
- Backend: Express
- Database: MySQL, Knex.js
- Infrastructure: GCP, Kubernetes, Docker
- CI/CD: CircleCI

## Requirements
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)

## Kubernetes on Minikube
```bash
# Start minikube
$ minikube start

# Create secret
$ kubectl create secret generic mysql-password --from-literal MYSQL_PASSWORD=<YOUR_PASSWORD>

# Set up nginx ingress controller (https://kubernetes.github.io/ingress-nginx/deploy/)
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
$ minikube addons enable ingress

# Apply k8s
$ kubectl apply -f k8s

# Find IP
$ minikube ip
```
You can access to your browser with minikube ip now.

## Set Up Cluster
```bash
# Login
$ gcloud auth login

# Set projects
$ gcloud config set project [PROJECT_ID]

# Activate project
$ export PROJECT_ID="$(gcloud config get-value project -q)"

# Get cluster credential
$ gcloud container clusters get-credentials travel-brochure

# Create serivce account (https://helm.sh/docs/using_helm/#gke)
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

# Initialize helm
$ helm init --service-account tiller --upgrade

# Set up nginx ingress controller
$ helm install stable/nginx-ingress --name nginx --set rbac.create=true

# Create secret
$ kubectl create secret generic mysql-password --from-literal MYSQL_PASSWORD=<YOUR_PASSWORD>
$ kubectl create secret generic travel-brochure-api-secret --from-env-file=envs/.env.api
# kubectl create secret generic travel-brochure-mysql-secret --from-env-file=envs/.env.mysql

# Apply k8s
$ kubectl apply -f k8s

# Find nginx EXTERNAL-IP to access on brower
$ kubectl get service
```

## Access To Database from API
```bash
$ kubectl get pods
$ kubectl exec -it <DEPLOYMENT> bash
$ mysql -h travel-brochure-mysql-cluster-ip-service -u admin -P 3306 -u root -p
```

## Add-On To Reduce Resources Utilization
```bash
# Disable Stackdriver Logging
$ gcloud container clusters update travel-brochure --logging-service none

# Disable Stackdriver Monitoring
$ gcloud beta container clusters update travel-brochure --monitoring-service none

# Disable Horizontal Pod Autoscaler
$ gcloud container clusters update travel-brochure --update-addons=HorizontalPodAutoscaling=DISABLED

# Disable Merics Server
$ kubectl --namespace=kube-system scale deployment metrics-server-v0.3.1 --replicas=0

# Reduce resources for kube dns
$ kubectl scale --replicas=0 deployment/kube-dns-autoscaler --namespace=kube-system
$ kubectl scale --replicas=1 deployment/kube-dns --namespace=kube-system
```

References:
- https://qiita.com/tachesimazzoca/items/4866d54853111bdcd489


## Cert Manager
To install cert manager on your cluster, please follow the document
- [Cert Manager](https://github.com/jetstack/cert-manager)
```bash
# Create namespace for cert manager
$ kubectl create namespace cert-manager

# Disable resource validation on the cert-manager namespace
$ kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install the CustomResourceDefinitions and cert-manager itself
$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.8.1/cert-manager.yaml --validate=false

# Verifying the installation
$ kubectl get pods --namespace cert-manager
```

See `k8s/issuer.yaml` for setting up issuer.
See `k8s/cetificate.yaml` for setting up certificate.


## Migration
```bash
# Get API pod name
$ kubectl get pods

# Access to API pod
$ kubectl exec -it <POD_NAME> bash

# Migrate
$ knex migrate:latest --env production
```

## Set Up Helm on GKE
Need additional installation for deployment.
```bash
# Installing helm (https://helm.sh/docs/using_helm/#installing-helm)
$ curl -LO https://git.io/get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

## Use Service Account Key In CircleCI
- [Encoding Multi-Line Environment Variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project)

```bash
# Encode service-account.json
$ openssl base64 -A -in gcloud-service-key.json -out encoded-gcloud-service-key.json
Zm9vYmFyCg==

# Set the result value in a CircleCI environment variable
$ echo $GCLOUD_SERVICE_KEY
Zm9vYmFyCg==

# Decoding service-account.json in a CircleCI
$ echo $GCLOUD_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-service-key.json
```

## How To Stop/Restart GKE Cluster
```bash
# Stop cluster
$ gcloud container clusters resize travel-brochure --size=0 --zone=us-central1-a

# Restart cluster
$ gcloud container clusters resize travel-brochure --size=1 --zone=us-central1-a
```
The command `gcloud compute instances stop <INSTANCE_NAMES>` does not work for GKE cluster

## Reference
- [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx)
