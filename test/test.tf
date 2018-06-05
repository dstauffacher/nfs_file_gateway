data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["aws-storage-gateway-file-*"]
  }
}

resource "random_pet" "pet_name" {}

module "storage_gateway" {
  source           = "https://github.com/dstauffacher/nfs_file_gateway.git"
  instance_type    = "m4.xlarge"
  application      = "${random_pet.pet_name.id}"
  environment      = "sandbox"
  vpc_id           = "${var.vpc_id}"
  role             = "experiment"
  lifespan         = "temporary"
  line_of_business = "IT_Department"
  customer         = "Contoso"
  instance_ami     = "${data.aws_ami.ami.image_id}"
  region           = "us-east-1"
  bucket_name      = "test_bucket"
  gateway_name     = "file_gateway_001"
  key_name         = "my_account_key"
}

resource "aws_security_group_rule" "ingress_80_tcp" {
  description       = "For activation from main campus"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${module.storage_gateway.storage_gateway_security_group_id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["insert_your_cidr_range_here"]  # todo
}
