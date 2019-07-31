# ---------------
# API Gateway that maps a single path:
#
# /profile: Goes to the 'profile' Function Compute function
# ---------------
resource "alicloud_api_gateway_group" "serverless-backend" {
  name = "ServerlessBackend"
  description = "Serverless backend"
}

resource "alicloud_api_gateway_api" "profile-api" {
  name = "ProfileEndpoint"
  description = "Retrieves and updates profiles for users"
  auth_type = "ANONYMOUS"
  group_id = alicloud_api_gateway_group.serverless-backend.id

  service_type = "FunctionCompute"

  fc_service_config {
    region = var.region
    service_name = alicloud_fc_service.serverless.name
    function_name = alicloud_fc_function.profile.name
    arn_role = alicloud_ram_role.gateway-role.arn
    timeout = 3000
  }

  request_config {
    protocol = "HTTP"
    method = "ANY"
    path = "/profile"
    mode = "MAPPING"
  }

  request_parameters {
    name = "X-User-Id"
    type = "STRING"
    required = "REQUIRED"
    in = "HEAD"
    in_service = "HEAD"
    name_service = "X-User-Id"
  }
}
