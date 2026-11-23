# Plans only, against a mocked AWS provider. Nothing touches AWS.
mock_provider "aws" {}

variables {
  bucket_name = "reports-example-com"
  tags = {
    cost-center = "CC-1234"
    owner       = "platform@example.com"
    environment = "dev"
    project     = "billing-reports"
  }
}

run "compliant_tags_plan" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.tags["cost-center"] == "CC-1234"
    error_message = "cost-center tag not applied"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["managed-by"] == "terraform"
    error_message = "managed-by tag not added"
  }

  assert {
    condition     = length(aws_s3_bucket.this.tags) == 5
    error_message = "expected the four input tags plus managed-by"
  }
}

run "missing_owner_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [aws_s3_bucket.this]
}

run "custom_required_tag_is_enforced" {
  command = plan

  variables {
    required_tags = ["cost-center", "owner", "environment", "project", "team"]
  }

  expect_failures = [aws_s3_bucket.this]
}

run "bad_cost_center_format_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "1234"
      owner       = "platform@example.com"
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [aws_s3_bucket.this]
}

run "blank_value_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      owner       = "  "
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [var.tags]
}

run "uppercase_key_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      Owner       = "platform@example.com"
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [var.tags]
}

run "unknown_environment_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      owner       = "platform@example.com"
      environment = "sandbox"
      project     = "billing-reports"
    }
  }

  expect_failures = [var.tags]
}

run "empty_required_tags_is_rejected" {
  command = plan

  variables {
    required_tags = []
  }

  expect_failures = [var.required_tags]
}

run "smaller_required_set_is_allowed" {
  command = plan

  variables {
    required_tags = ["cost-center"]
    tags = {
      cost-center = "CC-0042"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags["cost-center"] == "CC-0042"
    error_message = "a module caller can narrow required_tags"
  }
}

run "empty_string_value_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      owner       = ""
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [var.tags]
}

# Values are case-sensitive: "Prod" is not "prod", so billing reports can't split.
run "environment_value_case_is_enforced" {
  command = plan

  variables {
    tags = {
      cost-center = "CC-1234"
      owner       = "platform@example.com"
      environment = "Prod"
      project     = "billing-reports"
    }
  }

  expect_failures = [var.tags]
}

run "lowercase_cost_center_prefix_is_rejected" {
  command = plan

  variables {
    tags = {
      cost-center = "cc-1234"
      owner       = "platform@example.com"
      environment = "dev"
      project     = "billing-reports"
    }
  }

  expect_failures = [aws_s3_bucket.this]
}

run "uppercase_required_tag_key_is_rejected" {
  command = plan

  variables {
    required_tags = ["Cost-Center"]
  }

  expect_failures = [var.required_tags]
}

run "no_tags_at_all_is_rejected" {
  command = plan

  variables {
    tags = {}
  }

  expect_failures = [aws_s3_bucket.this]
}
