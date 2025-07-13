module "eks-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::account-id:role/role-name"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users    = []
  aws_auth_accounts = []

  depends_on = [module.eks]
}
