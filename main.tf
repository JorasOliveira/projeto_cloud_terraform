# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
}


#configure the backend
terraform {
  #required aws provider and version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  #s3 bucket to save the state file
  backend "s3" {
    bucket  = "jj-terraform-state-bucket"
    key     = "terraform.tsstate"
    region  = "us-east-1"
    encrypt = true
  }
}

