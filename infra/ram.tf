# ---------------
# Defines two roles: function-execution-role and gateway-role.
#
# function-execution-role: Assumed by Function Compute functions when running the code. Allows access
#     to Log Service and Table Store instance and tables.
#
# gateway-role: Assumed by API Gateway when calling the Function Compute integrations. Give API Gateway
#     permission to execute the two Function Compute functions.
# ---------------
resource "alicloud_ram_role" "function-execution-role" {
  name = "function-execution-role"
  document = <<EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "fc.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
    }
    EOF
  force = true
}

resource "alicloud_ram_policy" "table-store-access" {
  name = "table-store-access"
  force = true
  document = <<EOF
    {
      "Statement": [
        {
          "Action": [
            "ots:*"
          ],
          "Effect": "Allow",
          "Resource": [
            "acs:ots:${var.region}:${var.account}:instance/${alicloud_ots_instance.serverless.name}/",
            "acs:ots:${var.region}:${var.account}:instance/${alicloud_ots_instance.serverless.name}/table/${alicloud_ots_table.profile.table_name}",
            "acs:ots:${var.region}:${var.account}:instance/${alicloud_ots_instance.serverless.name}/table/${alicloud_ots_table.project.table_name}"
          ]
        }
      ],
      "Version": "1"
    }
    EOF
}

resource "alicloud_ram_policy" "log-access" {
  name = "log-access"
  force = true
  document = <<EOF
    {
      "Statement": [
        {
          "Action": [
            "log:*"
          ],
          "Effect": "Allow",
          "Resource": [
            "acs:log:${var.region}:${var.account}:project/${alicloud_log_project.serverless.name}/logstore/${alicloud_log_store.serverless-logs.name}"
          ]
        }
      ],
      "Version": "1"
    }
    EOF
}

resource "alicloud_ram_role_policy_attachment" "table-store-access-attachment" {
  policy_name = alicloud_ram_policy.table-store-access.name
  policy_type = "Custom"
  role_name = alicloud_ram_role.function-execution-role.name
}

resource "alicloud_ram_role_policy_attachment" "log-access-attachment" {
  policy_name = alicloud_ram_policy.log-access.name
  policy_type = "Custom"
  role_name = alicloud_ram_role.function-execution-role.name
}

resource "alicloud_ram_role" "gateway-role" {
  name = "gateway-role"
  force = true
  document = <<EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "apigateway.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
    }
    EOF
}

resource "alicloud_ram_policy" "function-compute-access" {
  name = "function-compute-access"
  force = true
  document = <<EOF
    {
      "Statement": [
        {
          "Action": [
            "fc:InvokeFunction"
          ],
          "Effect": "Allow",
          "Resource": [
            "acs:fc:${var.region}:${var.account}:services/${alicloud_fc_service.serverless.name}/functions/${alicloud_fc_function.profile.name}"
          ]
        }
      ],
      "Version": "1"
    }
    EOF
}

resource "alicloud_ram_role_policy_attachment" "function-compute-access-attachment" {
  policy_name = alicloud_ram_policy.function-compute-access.name
  policy_type = "Custom"
  role_name = alicloud_ram_role.gateway-role.name
}