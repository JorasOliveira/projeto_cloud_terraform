# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "jj-norad-data"
}
