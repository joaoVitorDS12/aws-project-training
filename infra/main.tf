/*
  AWS Project Training

  Projeto focado em infraestrutura como código utilizando:
  - AWS
  - Terraform
  - CloudFront
  - Application Load Balancer
  - Auto Scaling Group
  - EC2
  - IAM
  - S3

  Objetivo:
  Simular um ambiente real de produção com foco em:
  escalabilidade, confiabilidade e automação.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}