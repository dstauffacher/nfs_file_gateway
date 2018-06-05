data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      "${aws_s3_bucket.gateway_bucket.arn}",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.gateway_bucket.arn}/*",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "storagegateway.amazonaws.com",
      ]

      type = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = "${var.application}-${var.environment}-${var.role}-bucket-access"
  policy = "${data.aws_iam_policy_document.policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = "[your iam role ID goes here]" #todo enter this value
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
}
