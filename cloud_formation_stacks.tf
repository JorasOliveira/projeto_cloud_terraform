# Cloud Formation 1: Creating a stack for defining the Mission Profile
resource "aws_cloudformation_stack" "mission_profile" {
  name = "missionProfileStack"
  template_url = "https://aws-gs-blog.s3.us-east-2.amazonaws.com/cfn/aqua-rt-stps.yml"

  parameters = {
    CreateReceiverInstance = "false"
    InstanceType           = "m5.4xlarge"
    S3Bucket               = aws_s3_bucket.bucket.id
    SSHCidrBlock           = "172.16.0.0/20" #enter the public IP address of the computer you will use to conect to the EC2 instance
    SSHKeyName             = "osm"   #enter the name of the SSH key pair you will use to connect to the EC2 instance
    SatelliteName          = "AQUA"
    SubnetId               = aws_subnet.subnet.id 
    VpcId                  = aws_vpc.vpc.id  
  }

  capabilities = ["CAPABILITY_IAM"]
}

#creating the processor stack
resource "aws_cloudformation_stack" "data_processing" {
  name = "data-processor"
  template_url = "https://aws-gs-blog.s3.us-east-2.amazonaws.com/cfn/ipopp-instance.yml"

  parameters = {
    InstanceType           = "m5.4xlarge"
    IpoppPassword          = "Pl34s3CH4nG3M3" #password for the ipopp user in centOS, must be at least 8 characters in lenght
    S3Bucket               = aws_s3_bucket.bucket.id
    SSHCidrBlock           = "172.16.0.0/20" #enter the public IP address of the computer you will use to conect to the EC2 instance
    SSHKeyName             = "osm"   #enter the name of the SSH key pair you will use to connect to the EC2 instance
    SatelliteName          = "AQUA"
    SubnetId               = aws_subnet.subnet.id 
    VpcId                  = aws_vpc.vpc.id  
  }

  capabilities = ["CAPABILITY_IAM"]
}