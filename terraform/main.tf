provider "aws" {
  region = "eu-west-1"
}

### -------------------------------
### VPC Module
### -------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}

### -------------------------------
### EKS Module
### -------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name             = "eks-cluster"
  cluster_version          = "1.32"
  subnet_ids               = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2] ]
  control_plane_subnet_ids = [ module.vpc.private_subnets[3], module.vpc.private_subnets[4], module.vpc.private_subnets[5] ]
  vpc_id                   = module.vpc.vpc_id
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_encryption_config       = {}
  enable_irsa                     = true
  cluster_security_group_additional_rules = {
    vpn-azure = {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_groups = {
    "k8s-nodegroup-A" = {
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.32.1-20250410"
      desired_size        = 1
      max_size            = 1
      min_size            = 0
      instance_types = ["t3.medium"]
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

### -------------------------------
### Kubernetes Provider using exec auth
### -------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

### -------------------------------
### Helm Provider using exec auth (correct syntax)
### -------------------------------
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

### -------------------------------
### Helm Release Deployment
### -------------------------------
resource "helm_release" "currency_converter" {
  name             = "currency-converter"
  chart            = "../helm/currency-converter"
  namespace        = "currency-converter"
  create_namespace = true

  values = [
    file("../helm/currency-converter/values.yaml")
  ]
  depends_on = [module.eks-auth]
}
