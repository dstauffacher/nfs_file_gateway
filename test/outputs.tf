output "gateway_ip_address" {
  value       = "${module.storage_gateway.gateway_ip_address}"
  description = "the IP address assigned to the gateway EC2 instance - needed to activate the gateway"
}

output "gateway_instance_id" {
  value       = "${module.storage_gateway.gateway_instance_id}"
  description = "the ID of the file gateway EC2 instance - needed to populate a command that pauses the activation process until the gateway instance is fully online and available"
}

output "s3_bucket_arn" {
  value       = "${module.storage_gateway.s3_bucket_arn}"
  description = "the ARN of the S3 bucket used as back-end storage - needed to create the file share once the gateway is online"
}

output "gateway_name" {
  value       = "${module.storage_gateway.gateway_name}"
  description = "the friendly name of the gateway - needed for querying other details about the gateway"
}

output "role_policy_arn" {
  value       = "${module.storage_gateway.role_policy_arn}"
  description = "the role policy is used in the share creation command"
}

output "region" {
  value       = "${module.storage_gateway.region}"
  description = "the region in which the gateway is being deployed - needed for creating the file share"
}

output "gateway_fqdn" {
  value       = "${module.storage_gateway.gateway_fqdn}"
  description = "The FQDN of the gateway"
}

output "application" {
  value       = "${module.storage_gateway.application}"
  description = "The name application using this storage gateway"
}

output "environment" {
  value       = "${module.storage_gateway.environment}"
  description = "The environment into which the gateway is being deployed"
}

output "role" {
  value       = "${module.storage_gateway.role}"
  description = "role this gateway is serving"
}

output "line_of_business" {
  value       = "${module.storage_gateway.line_of_business}"
  description = "for which line of business is this resource created?"
}

output "lifespan" {
  value       = "${module.storage_gateway.lifespan}"
  description = "How long do these resources live?"
}

output "customer" {
  value       = "${module.storage_gateway.customer}"
  description = "is this for a specific customer?"
}

output "owner_email" {
  value       = "${module.storage_gateway.owner_email}"
  description = "email address for the owner of this gateway"
}

output "creator_arn" {
  value       = "${module.storage_gateway.creator_arn}"
  description = "the creator arn"
}

output "storage_gateway_security_group_id" {
  value       = "${module.storage_gateway.storage_gateway_security_group_id}"
  description = "The security group id for the storage gateway"
}

output "storage_gateway_management_access_security_group_id" {
  value       = "${module.storage_gateway.storage_gateway_access_management_security_group_id}"
  description = "The id of the security group to attach to your instances to get NFS access to the storage gateway"
}

output "storage_gateway_product_access_security_group_id" {
  value       = "${module.storage_gateway.storage_gateway_access_product_security_group_id}"
  description = "The id of the security group to attach to your instances to get NFS access to the storage gateway"
}
