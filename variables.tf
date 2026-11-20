variable "bucket_name" {
  description = "Name of the S3 bucket to create."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 lowercase letters, digits, dots or hyphens."
  }
}

variable "required_tags" {
  description = "Tag keys every resource from this module must carry."
  type        = list(string)
  default     = ["cost-center", "owner", "environment", "project"]

  validation {
    condition     = length(var.required_tags) > 0
    error_message = "required_tags must list at least one tag key."
  }

  validation {
    condition     = alltrue([for k in var.required_tags : can(regex("^[a-z][a-z0-9-]*$", k))])
    error_message = "required_tags keys must be lowercase, e.g. cost-center."
  }
}

variable "tags" {
  description = "Cost-allocation tags. Must include every key in required_tags."
  type        = map(string)

  # Lowercase keys only, so "Owner" and "owner" can't split the bill.
  validation {
    condition     = alltrue([for k in keys(var.tags) : can(regex("^[a-z][a-z0-9-]*$", k))])
    error_message = "Tag keys must be lowercase letters, digits and hyphens, e.g. cost-center."
  }

  validation {
    condition     = alltrue([for v in values(var.tags) : trimspace(v) != ""])
    error_message = "Tag values must not be empty or blank."
  }

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], lookup(var.tags, "environment", "dev"))
    error_message = "The environment tag must be one of dev, test, staging, prod."
  }
}
