# Copiar o arquivo RT-STPS_7.0.tar.gz para o bucket S3
resource "null_resource" "copy_RT_STPS_7_0" {
  provisioner "local-exec" {
    command = "aws s3 cp nasa_files/software/RT-STPS/RT-STPS_7.0.tar.gz s3://jj-norad-data/software/RT-STPS/"
  }
}

# Copiar o arquivo RT-STPS_7.0_PATCH_1.tar.gz para o bucket S3
resource "null_resource" "copy_RT_STPS_7_0_PATCH_1" {
  provisioner "local-exec" {
    command = "aws s3 cp nasa_files/software/RT-STPS/RT-STPS_7.0_PATCH_1.tar.gz s3://jj-norad-data/software/RT-STPS/"
  }
}

# Copiar o arquivo receivedata.py para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_receivedata_py" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/receivedata.py s3://jj-norad-data/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo awsgs.py para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_awsgs_py" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/awsgs.py s3://jj-norad-data/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo start-data-capture.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_start_data_capture_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/start-data-capture.sh s3://jj-norad-data/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo ipopp-ingest.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_ipopp_ingest_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/IPOPP/ipopp-ingest.sh s3://jj-norad-data/software/IPOPP/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo install-ipopp.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_install_ipopp_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/IPOPP/install-ipopp.sh s3://jj-norad-data/software/IPOPP/ --source-region us-east-2 --region us-east-1"
  }
}
