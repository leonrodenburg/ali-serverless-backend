# ---------------
# Creates two Table Store tables in a single instance.
#
# profile: Stores user profile data. Primary key consists of only the userId.
# projects: Used to store the users' projects. Primary key is composite, containing both userId and projectId
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
    name = "userId"
    type = "String"
  }
}

resource "alicloud_ots_table" "project" {
  instance_name = alicloud_ots_instance.serverless.name
  table_name = "project"
  max_version = 1
  time_to_live = -1

  primary_key {
    name = "userId"
    type = "String"
  }

  primary_key {
    name = "projectId"
    type = "String"
  }
}