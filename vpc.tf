
resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16" #enter the CIDR block you want to use for the VPC
  tags = {
    Name = "VPC_AQUA"
  }
}

#then create a subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.31.0.0/16" #enter the CIDR block you want to use for the subnet
  availability_zone       = "us-east-1a" #enter the availability zone you want to use for the subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_AQUA"
  }
}