# ---------------
# Creates a single OSS bucket to store code for Function Compute functions.
# ---------------
resource "alicloud_oss_bucket" "serverless-code" {
  bucket = "serverless-code-bucket"
}