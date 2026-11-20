locals {
  tags = merge(var.tags, { "managed-by" = "terraform" })

  missing_tags = sort(setsubtract(var.required_tags, keys(local.tags)))
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = local.tags

  lifecycle {
    # Checked here, not in the variable, because it compares two inputs.
    precondition {
      condition     = length(local.missing_tags) == 0
      error_message = "Missing mandatory tags: ${join(", ", local.missing_tags)}."
    }

    precondition {
      condition     = can(regex("^CC-[0-9]{4}$", lookup(local.tags, "cost-center", "CC-0000")))
      error_message = "cost-center must look like CC-1234."
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
