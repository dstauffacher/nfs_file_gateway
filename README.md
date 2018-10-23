# file_gateway_automation
# A new version of this work can be found here:  https://github.com/dstauffacher/terraform_file_gateway

## This module has been deprecated, as Terraform now supports the file gateway activation process.  Use the new link above.

## The following is for reference purposes only
#### This module creates the following infrastructure:
* aws_instance (default is m4.xlarge) launched from the storage gateway AMI
    * with attached ebs volume (default 150 GB, GP2) attached to the EC2 instance
* aws_security_group to grant NFS access to the gateway
* aws_iam_policy
* aws_iam_role_policy
* aws_s3_bucket for the back-end storage 


#### Other details:
This infrastructure is launched by running the gateway-apply.sh script.  This script deploys the terraform to stand up the environment, and then configures the environment through a series of aws-cli calls based on output from the terraform.


## Cost Information

Use of this module will incur fees. More specifically, the cost of one EC2 instance.
To determine the exact cost of this instance; see Amazon's EC2 pricing page:
https://aws.amazon.com/ec2/pricing/on-demand/ and Amazon's S3 pricing page:  https://aws.amazon.com/s3/pricing/

## Usage Examples

This terraform is launched from the gateway-apply.sh script found in this project.  You will need to run this file during the build of your project and create your terraform similar to that in the readme.md.  Run the gateway-apply.sh script to stand up your environment.

Note - to tear down a gateway environment, the gateway must first be deleted, then the underlying infrastructure destroyed via terraform.  When you run the gateway.sh script, it will automatically create a script that can be used to tear down the environment.

```
bash ./gateway-apply.sh
```

### Terraform for NFS access from a windows server to the file gateway 
```hcl-terraform
data "aws_security_group" "file_gateway_access" {
  name   = "sql-${var.environment}-backup-storage-gateway-access"
  vpc_id = "${var.vpc_id}"
}

# Then attach this security group to your EC2 instances
resource "aws_instance" "windows_server" {
  # ...
  vpc_security_group_ids = ["${concat(module.launch_pad.security_groups, list(data.aws_security_group.file_gateway_access))}"]
}
```

### Example Terraform for standing up the gateway.
```hcl-terraform
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["aws-storage-gateway-file-*"]
  }
}

data "aws_region" "current" {}


module "storage_gateway" {
  source            = "[git repo goes here"   #todo add your value here
  instance_type     = "m4.xlarge"
  application       = "test-gateway"
  environment       = "sandbox"
  vpc_id            = "${var.vpc_id}"
  role              = "experiment"
  lifespan          = "temporary"
  line_of_business  = "Sales"
  customer          = "Contoso"
  instance_ami      = "${data.aws_ami.ami.image_id}"
  region            = "${data.aws_region.current.name}"
  bucket_name       = "my_install_media"
  gateway_name      = "install_media_contoso_sales"
  key_name          = "contoso_key"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application | The name application using this storage gateway | string | - | yes | | bucket_name | The friendly name of the bucket that will be the backend of the storage gateway | string | - | yes |
| customer | is this for a specific customer? | string | `` | no |
| ebs_cache_volume_size | The size in GB of the EBS cache volume. (Optional) Default is 150 GB. | string | `150` | no |
| environment | The environment into which the gateway is being deployed | string | - | yes |
| gateway_name | The friendly name of the storage gateway.  This is needed for commands run as part of the gateway configuration. | string | - | yes |
| instance_ami | the name of the storage gateway AMI to launch.  this value should be looked up via data module | string | - | yes |
| instance_type | The type of instance to host the gateway.  Reference AWS documentation for supported instance types. | string | `m4.xlarge` | no |
| key_name | the name of the key to be used when accessing the instance | string | - | yes |
| lifespan | How long do these resources live? | string | `temporary` | no |
| line_of_business | for which line of business is this resource created? | string | - | yes |
| owner_email | email address for the owner of this gateway | string | `user@contoso.com` | no |
| region | The region in which the resources are launched | string | `us-east-1` | no |
| role | role this gateway is serving | string | - | yes |
| vpc_id | The VPC id into which this gateway should be launched | string | - | yes |


## Outputs

| Name | Description |
|------|-------------|
| application | The name application using this storage gateway |
| creator_arn | the creator arn |
| customer | is this for a specific customer? |
| environment | The environment into which the gateway is being deployed |
| gateway_fqdn | The FQDN of the gateway |
| gateway_instance_id | the ID of the file gateway EC2 instance - needed to populate a command that pauses the activation process until the gateway instance is fully online and available |
| gateway_ip_address | the IP address assigned to the gateway EC2 instance - needed to activate the gateway |
| gateway_name | the friendly name of the gateway - needed for querying other details about the gateway |
| lifespan | How long do these resources live? |
| line_of_business | for which line of business is this resource created? |
| owner_email | email address for the owner of this gateway |
| region | the region in which the gateway is being deployed - needed for creating the file share |
| role | role this gateway is serving |
| role_policy_arn | the role policy is used in the share creation command |
| s3_bucket_arn | the ARN of the S3 bucket used as back-end storage - needed to create the file share once the gateway is online |
| storage_gateway_access_management_security_group_id | The id of the security group to attach to your instances to get NFS access to the storage gateway |
| storage_gateway_access_product_security_group_id | The id of the security group to attach to your instances to get NFS access to the storage gateway |
| storage_gateway_security_group_id | The security group id for the storage gateway |


## Version History

v1.0 - Initial Release
 instead of relying on consumers to create SG rules
