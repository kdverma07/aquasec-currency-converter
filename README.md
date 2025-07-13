# Currency Converter Microservice

This project implements a Python FastAPI microservice for real-time currency conversion, containerized with Docker, deployed via Helm on Kubernetes, and provisioned using Terraform on AWS EKS.

## 🚀 Features

- Convert currencies using live rates from exchangerate.host.
- REST endpoint: `/convert?from=USD&to=EUR&amount=100`.
- Dockerized microservice.
- CI/CD pipeline with GitHub Actions.
- Helm chart for Kubernetes deployment.
- Terraform scripts to provision EKS and deploy the app.

## 🛠️ Setup

### 1. Build and Run Locally

```bash
docker build -t currency-converter .
docker run -d -p 8000:8000 -e OPENEXCHANGERATES_APP_ID=your_real_api_key currency-converter # Replace your_real_api_key with the api_key

Access at: http://localhost:8000/

2. CI/CD Pipeline

Triggered on push to main.

Builds Docker image and pushes to Docker Hub.

Lints Helm chart.

#Required GitHub Secrets
Secret	Description
DOCKERHUB_USERNAME	Docker Hub username
DOCKERHUB_TOKEN	        Docker Hub access token

3. Helm Deployment

helm install currency-converter ./helm/currency-converter \
  --set image.repository=kdverma07/currency-converter \
  --set image.tag=latest \
  --set app.appId=APP_ID

#Required 
APP_ID needs to be replaced with the app_id of https://openexchangerates.org/account/app-ids

4. Terraform Infrastructure

cd terraform
terraform init
terraform plan
terraform apply
Outputs include the EKS cluster endpoint.

#Required
Make sure Login is done with Access key and Secret access key of the user having enough permission to be able to create all terraform resources.
Also while running via terraform to deploy helm chart, make sure values file is correctly updated with all values.

To Verify service run below command
kubectl port-forward svc/currency-converter 8000:80 -n currency-converter

And access the GUI at http://localhost:8000/
