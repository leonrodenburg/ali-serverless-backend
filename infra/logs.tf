# ---------------
# Log Service project and store.
# ---------------
resource "alicloud_log_project" "serverless" {
  name = "serverless-logs-project"
  description = "Logs for functions triggered by API Gateway"
}

resource "alicloud_log_store" "serverless-logs" {
  project = alicloud_log_project.serverless.name
  name = "serverless-logs-store"
  shard_count = 2
}