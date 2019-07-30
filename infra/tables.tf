# ---------------
# Creates a single Table Store table in a single instance.
#
# profile: Stores user profile data. Simple primary key with only the user ID.
# ---------------
resource "alicloud_ots_instance" "serverless" {
  name = "serverless"
  instance_type = "Capacity"
}

resource "alicloud_ots_table" "profile" {
  instance_name = alicloud_ots_instance.serverless.name
  table_name = "profile"
  max_version = 1
  time_to_live = -1

  primary_key {
    name = "id"
    type = "String"
  }
}