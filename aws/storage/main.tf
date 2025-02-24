locals {
  bucket_id  = var.create_bucket ? aws_s3_bucket.bufstream[0].id : data.aws_s3_bucket.bufstream[0].id
  bucket_arn = var.create_bucket ? aws_s3_bucket.bufstream[0].arn : data.aws_s3_bucket.bufstream[0].arn
}

resource "aws_s3_bucket" "bufstream" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name
}

data "aws_s3_bucket" "bufstream" {
  count  = var.create_bucket ? 0 : 1
  bucket = var.bucket_name
}

data "aws_iam_policy_document" "secure_only" {
  # Enforce SSL/TLS on all transmitted objects
  statement {
    sid    = "enforce-tls-requests-only"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${local.bucket_id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  count  = var.create_bucket ? 1 : 0
  bucket = local.bucket_id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "bucket_access" {
  count  = var.create_bucket ? 1 : 0
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.secure_only.json
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count                   = var.create_bucket ? 1 : 0
  bucket                  = local.bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "bufstream_s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.bucket_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_access" {
  policy = data.aws_iam_policy_document.bufstream_s3.json
}

resource "aws_iam_role_policy_attachment" "bufstream" {
  policy_arn = aws_iam_policy.s3_access.arn
  role       = var.bufstream_role
}
