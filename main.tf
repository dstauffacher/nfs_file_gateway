data "aws_vpc" "deployment_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "zone_name" {
  name = "${data.aws_vpc.deployment_vpc.tags["DNSZone"]}"
}

resource "random_integer" "priority" {
  min = 1
  max = "${length(data.aws_subnet_ids.subnets.ids)}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.deployment_vpc.id}"

  tags {
    Type = "private"
  }
}

resource "aws_instance" "gateway" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"

  # Refer to AWS File Gateway documentation for minimum system requirements.
  ebs_optimized = true
  subnet_id     = "${element(data.aws_subnet_ids.subnets.ids, random_integer.priority.result)}"

  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = "${var.ebs_cache_volume_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  key_name = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.storage_gateway.id}",
  ]

  volume_tags = {
      "Name" = "${var.application}-${var.environment}-${var.role}",
      "Role" = "${var.role}",
      "GatewayName" = "${var.gateway_name}"
      }

  tags = {
      "Name" = "${var.application}-${var.environment}-${var.role}",
      "Role" = "${var.role}",
      "GatewayName" = "${var.gateway_name}"
    }
}

resource "aws_route53_record" "gateway_A_record" {
  zone_id = "${data.aws_route53_zone.zone_name.zone_id}"
  name    = "${var.gateway_name}"
  type    = "A"
  ttl     = "3600"
  records = ["${aws_instance.gateway.private_ip}"]
}

resource "aws_s3_bucket" "gateway_bucket" {
  bucket = "${var.bucket_name}"
  region = "${var.region}"
  acl = "private"

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    fqdn = "${aws_route53_record.gateway_A_record.fqdn}"
    application = "${var.application}"
    environment = "${var.environment}"
    role = "${var.role}"
    line_of_business = "${var.line_of_business}"
    lifespan ="${var.lifespan}"
    owner_email = "${var.owner_email}"
  }

}
