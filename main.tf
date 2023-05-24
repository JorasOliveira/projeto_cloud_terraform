# Configure the AWS Provider
provider "aws" {
  version = "~> 3.37"
  region  = "us-east-1"
}


# Criando bucket para salvar o Estado da Infraestrutura
terraform {
  backend "s3" {
    bucket  = "jj-terraform-state-bucket"
    key     = "terraform.tsstate"
    region  = "us-east-1"
    encrypt = true
  }
}

