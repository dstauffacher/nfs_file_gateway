output "gateway_ip_address" {
  value       = "${aws_instance.gateway.private_ip}"
  description = "the IP address assigned to the gateway EC2 instance - needed to activate the gateway"
}

output "gateway_instance_id" {
  value       = "${aws_instance.gateway.id}"
  description = "the ID of the file gateway EC2 instance - needed to populate a command that pauses the activation process until the gateway instance is fully online and available"
}

output "s3_bucket_arn" {
  value       = "${aws_s3_bucket.gateway_bucket.arn}"
  description = "the ARN of the S3 bucket used as back-end storage - needed to create the file share once the gateway is online"
}

output "role_policy_arn" {
  value       = "${[YOUR IAM ROLE POLICY ARN GOES HERE]}"  #todo add your value here
  description = "the role policy is used in the share creation command"
}

output "gateway_name" {
  value       = "${var.gateway_name}"
  description = "the friendly name of the gateway - needed for querying other details about the gateway"
}

output "region" {
  value       = "${var.region}"
  description = "the region in which the gateway is being deployed - needed for creating the file share"
}

output "gateway_fqdn" {
  value       = "${aws_route53_record.gateway_A_record.fqdn}"
  description = "The FQDN of the gateway"
}

output "application" {
  value       = "${var.application}"
  description = "The name application using this storage gateway"
}

output "environment" {
  value       = "${var.environment}"
  description = "The environment into which the gateway is being deployed"
}

output "role" {
  value       = "${var.role}"
  description = "role this gateway is serving"
}

output "line_of_business" {
  value       = "${var.line_of_business}"
  description = "for which line of business is this resource created?"
}

output "lifespan" {
  value       = "${var.lifespan}"
  description = "How long do these resources live?"
}

output "customer" {
  value       = "${var.customer}"
  description = "is this for a specific customer?"
}

output "owner_email" {
  value       = "${var.owner_email}"
  description = "email address for the owner of this gateway"
}

data "aws_caller_identity" "current" {}

output "creator_arn" {
  value       = "${data.aws_caller_identity.current.arn}"
  description = "the creator arn"
}

output "storage_gateway_security_group_id" {
  value       = "${aws_security_group.storage_gateway.id}"
  description = "The security group id for the storage gateway"
}

output "storage_gateway_access_management_security_group_id" {
  value       = "${aws_security_group.management_storage_gateway_access.id}"
  description = "The id of the security group to attach to your instances to get NFS access to the storage gateway"
}

output "storage_gateway_access_product_security_group_id" {
  value       = "${aws_security_group.product_storage_gateway_access.id}"
  description = "The id of the security group to attach to your instances to get NFS access to the storage gateway"
}
