# ---------------
# Creates two Table Store tables in a single instance.
#
# profile: Stores user profile data. Primary key consists of only the userId.
# projects: Used to store the users' projects. Primary key is composite, containing both userId and projectId
# ---------------
variable "profile-zip-key" {
  default = "profile.zip"
}

resource "alicloud_fc_service" "serverless" {
  name = "serverless"
  role = alicloud_ram_role.function-execution-role.arn

  log_config {
    project = alicloud_log_project.serverless.name
    logstore = alicloud_log_store.serverless-logs.name
  }

  depends_on = [
    alicloud_ram_role_policy_attachment.log-access-attachment
  ]
}

resource "alicloud_fc_function" "profile" {
  service = alicloud_fc_service.serverless.name
  name = "profile"
  runtime = "python3"
  handler = "function.handler"

  oss_bucket = alicloud_oss_bucket.serverless-code.id
  oss_key = var.profile-zip-key
}