terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

# O agente que monitora este banco roda dentro do cluster, e não na AWS: por
# isso este repositório, que sempre foi só de RDS, agora também fala com o
# Kubernetes. A alternativa seria declarar o agente em tc3-infra-k8s, mas lá o
# endpoint e a senha do banco ainda não existem — o cluster nasce antes.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.principal.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.principal.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.principal.name, "--region", var.aws_region]
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Ambiente  = var.environment
      ManagedBy = "terraform"
      Stack     = "infra-db"
    }
  }
}
