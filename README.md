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

Access at: http://localhost:8000/convert?from=USD&to=INR&amount=100

2. CI/CD Pipeline

Triggered on push to main.

Builds Docker image and pushes to Docker Hub.

Lints Helm chart.

Required GitHub Secrets
Secret	Description
DOCKERHUB_USERNAME	Docker Hub username
DOCKERHUB_TOKEN	        Docker Hub access token

3. Helm Deployment

helm install currency-converter ./helm/currency-converter \
  --set image.repository=yourdockerhubusername/currency-converter \
  --set image.tag=latest

4. Terraform Infrastructure

cd terraform
terraform init
terraform plan
terraform apply
Outputs include the EKS cluster endpoint and kubeconfig command.
