variable "application" {
  description = "The name application using this storage gateway"
}

variable "environment" {
  description = "The environment into which the gateway is being deployed"
}

variable "role" {
  description = "role this gateway is serving"
}

variable "line_of_business" {
  description = "for which line of business is this resource created?"
}

variable "lifespan" {
  description = "How long do these resources live?"
  default     = "temporary"
}

variable "customer" {
  description = "is this for a specific customer?"
  default     = ""
}

variable "owner_email" {
  description = "email address for the owner of this gateway"
  default     = "user@contoso.com"
}

variable "vpc_id" {
  description = "The VPC id into which this gateway should be launched"
}

variable "instance_type" {
  description = "The type of instance to host the gateway.  Reference AWS documentation for supported instance types."
  default     = "m4.xlarge"

  # Refer to AWS File Gateway documentation for minimum system requirements.
}

variable "instance_ami" {
  description = "the name of the storage gateway AMI to launch.  this value should be looked up via data module"
}

variable "region" {
  description = "The region in which the resources are launched"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The friendly name of the bucket that will be the backend of the storage gateway"
}

variable "gateway_name" {
  description = "The friendly name of the storage gateway.  This is needed for commands run as part of the gateway configuration."
}

variable "key_name" {
  description = "the name of the key to be used when accessing the instance"
}

variable "ebs_cache_volume_size" {
  description = "The size in GB of the EBS cache volume. (Optional) Default is 150 GB."
  default = "150"
}