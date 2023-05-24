# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "jj-norad-data"
}

# Download NASA's RT-STPS software from the NASA DRL website
# Upload the RT-STPS files to the S3 bucket
resource "aws_s3_bucket_object" "rt_stps_files" {

  for_each = fileset("software/RT_STPS/", "*")
  bucket = aws_s3_bucket.bucket.id
  key = each.value
  source = "nasa_files/software/${each.value}"
  etag = filemd5("nasa_files/software/${each.value}")
  
}

# Upload the data capture application code to the S3 bucket
resource "aws_s3_bucket_object" "data_capture_code" {

  for_each = fileset("software/data-receiver/", "*")
  bucket = aws_s3_bucket.bucket.id
  key    = each.value
  source = "s3://aws-gs-blog/software/data-receiver/${each.value}"
  
}

# Upload IPOPPapplication code to the S3 bucket
resource "aws_s3_bucket_object" "data_capture_code" {

  for_each = fileset("software/IPOPP/", "*")
  bucket = aws_s3_bucket.bucket.id
  key    = each.value
  source = "s3://aws-gs-blog/software/IPOPP/${each.value}"
  
}
