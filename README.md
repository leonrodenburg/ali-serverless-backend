# Alibaba Cloud serverless backend

Example project demonstrating how you can deploy a serverless backend on Alibaba Cloud. The services include API Gateway, Function Compute and Table Store. The resources are provisioned using Terraform. The whole stack is deployed using a CI/CD pipeline that runs on CircleCI.

To run this stack in your own account, you have two options. The first option is recommended.

## Deploying with CircleCI

This project contains a ready-to-go configuration for CircleCI that will automatically deploy the resources in your account. To start, create a free CircleCI account and hook it up to your own fork of this repository. Then, when you push to master, the pipeline will roll out a new version of the stack and code automatically.

To make sure the environment is configured correctly, make sure these environment variables are set in your CircleCI configuration for the project:

| Variable name       | Description                                                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| ALICLOUD_ACCESS_KEY | Access key ID for your account                                                                                            |
| ALICLOUD_SECRET_KEY | Secret key corresponding to access key                                                                                    |
| ALICLOUD_REGION     | Region where you want to deploy                                                                                           |
| OSS_CODE_BUCKET     | Bucket name that you set in `bucket.tf`. Bucket names should be globally unique so choose something that isn't taken yet. |
| TF_VAR_account      | The ID of your account                                                                                                    |
| TF_VAR_region       | Again the region you want to deploy                                                                                       |

With these variables set, you should be good to go! A push to master should be enough.

## Manually deploying with Terraform CLI

To deploy this in your own account, follow these steps:

1. Create an OSS bucket by hand that will hold your Terraform state
2. Update `_provider.tf` and put the bucket name as the value in the `bucket` property. Also update the region to the region where the bucket was created (e.g. `eu-central-1`)
3. Make sure your credentials are wired into the current environment:

   - `export ALICLOUD_ACCESS_KEY="--ACCESS KEY HERE--"`
   - `export ALICLOUD_SECRET_KEY="--SECRET KEY HERE--"`
   - `export TF_VAR_account="--ACCOUNT ID HERE--"`
   - `export TF_VAR_region="--REGION HERE--"`

   You can find your access keys under the 'AccessKey' link when you hover over your profile picture in the Alibaba Cloud console. The account ID can be found under 'User info'. You can decide upon the region yourself.

4. Install the dependencies for the Function Compute code in `src/profile` by using `pipenv`. More information on Pipenv can be [found here](https://docs.pipenv.org/en/latest/).
5. Zip up the function.py file including the installed dependencies and name it `project.zip`. For inspiration, you can look at the CircleCI configuration in `.circleci/config.yml`. Specifically, have a look at the `build_profile_function` job for details.
6. Update the `bucket.tf` file to create a differently named bucket for the Function Compute code. Because bucket names have to be globally unique, taking mine won't work.
7. Create the bucket using the Terraform CLI: `terraform apply -target=alicloud_oss_bucket.serverless-code`
8. Use any means at your disposal (console or CLI) to upload `project.zip` to the bucket you created in step 7.
9. Deploy the terraform stack: `terraform apply`

## Bug in Terraform provider

Because of a bug in the Terraform provider for Alibaba Cloud, the API Gateway definition cannot include the `stage_names` property to automatically deploy the endpoints to staging or production. For now, you will have to manually go to the Alibaba Cloud console, go to API Gateway, click 'APIs' and click the 'Deploy' button next to the 'ProfileEndpoint' function. This should be fixed when version 1.53 of the provider is released (see [#1486](https://github.com/terraform-providers/terraform-provider-alicloud/pull/1486) for more info.)
