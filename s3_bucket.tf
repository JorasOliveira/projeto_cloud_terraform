# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "jj-norad-data"
}



variable "source_directory" {
  description = "Path to the source directory containing files to upload"
  default     = "/nasa_files/software/"
}

variable "destination_prefix" {
  description = "Prefix to add to the destination S3 object keys"
  default     = "software/"
}

data "local_file" "files_to_upload" {
  for_each = fileset(var.source_directory, "*")
  filename = var.source_directory != "" ? "${var.source_directory}/${each.value}" : each.value
}

resource "aws_s3_object" "rt_stps_files" {
  for_each = data.local_file.files_to_upload

  bucket = aws_s3_bucket.bucket.id
  key    = "${var.destination_prefix}${each.key}"
  source = each.value.filename
}


# data "local_file" "file_to_upload" {
#   filename = "~/nasa_files/software/"
# }

# Download NASA's RT-STPS software from the NASA DRL website
# Upload the RT-STPS files to the S3 bucket
# resource "aws_s3_object" "rt_stps_files" {

#   for_each = fileset("software/RT_STPS/", "*")
#   bucket = aws_s3_bucket.bucket.id
#   key = each.value
#   source = "/nasa_files/software/${each.value}"
#   etag = filemd5("nasa_files/software/${each.value}")

# }

# Upload the data capture application code to the S3 bucket
resource "aws_s3_object" "data_capture_code" {

  for_each = fileset("software/data-receiver/", "*")
  bucket = aws_s3_bucket.bucket.id
  key    = each.value
  source = "aws-gs-blog/software/data-receiver/${each.value}"

}

# Upload IPOPPapplication code to the S3 bucket
resource "aws_s3_object" "IPOPP_files" {

  for_each = fileset("software/IPOPP/", "*")
  bucket = aws_s3_bucket.bucket.id
  key    = each.value
  source   = "aws-gs-blog/software/IPOPP/${each.value}"
  # source = "s3://aws-gs-blog/software/IPOPP/${each.value}"
  
}
