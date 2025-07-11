provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name             = "currency-converter-cluster"
  cluster_version          = "1.32"
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
  vpc_id                   = module.vpc.vpc_id

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  cluster_encryption_config = {} 
  enable_irsa               = true
  eks_managed_node_groups = {
    default = {
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.32.1-20250410"
      desired_size        = 2
      max_size            = 3
      min_size            = 1

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

resource "helm_release" "currency_converter" {
  name             = "currency-converter"
  chart            = "../helm/currency-converter"
  namespace        = "default"
  create_namespace = true

  values = [
    file("../helm/currency-converter/values.yaml")
  ]

  depends_on = [module.eks]
}

