// Adopts the account's two CloudTrail trails and the two S3 buckets they deliver to.
// All four predate any Terraform in this repo and were console-configured; audit logging
// is a security control, so it should not live only as console state.
// See hackforla/devops-security#191.
//
// The two trails are complementary, not redundant. With advanced event selectors a trail
// logs only what its selectors name, and devops-security-tf-backend-logs has no Management
// selector at all -- it watches S3 data events on the hfla-ops-terraform-state backend
// bucket and nothing else, while management-events carries the account's management
// events. Neither is an organization trail, so neither covers the payer account
// 504695638931.
//
// This file adopts what is there as-is. Four things are missing from both trails and are
// deliberately NOT added here, because each changes live behaviour and belongs in its own
// ticket: KMS encryption (both use SSE-S3), a CloudWatch Logs destination (so there is no
// alerting path off either trail), a bucket lifecycle configuration (logs accumulate
// indefinitely), and the disagreement over log file validation, which is reproduced below
// rather than resolved.
//
// A bucket is not one resource. Since AWS provider v4 the policy, public access block,
// encryption and ownership controls are each their own resource with their own import --
// the same trap terraform/import.tf in hackforla/incubator documents.

// ---------------------------------------------------------------------------
// devops-security-tf-backend-logs -- S3 data events on the Terraform backend bucket
// ---------------------------------------------------------------------------

resource "aws_s3_bucket" "tf_backend_logs" {
  bucket = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

// Reproduced verbatim from the live bucket. These two statements are what let CloudTrail
// deliver to the bucket at all -- if this policy drifts on apply, log delivery stops and
// nothing alerts; the trail simply stops writing.
//
// Note the condition key is spelled "aws:SourceArn" here and "AWS:SourceArn" on the
// management-events bucket below. IAM condition keys are case-insensitive, so the two are
// equivalent to AWS, and both are left exactly as stored. Normalising them would be a
// change to a live policy for no behavioural gain.
resource "aws_s3_bucket_policy" "tf_backend_logs" {
  bucket = aws_s3_bucket.tf_backend_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck20150319"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::aws-cloudtrail-logs-035866691871-4b8654bf"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:us-west-2:035866691871:trail/devops-security-tf-backend-logs"
          }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite20150319"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::aws-cloudtrail-logs-035866691871-4b8654bf/AWSLogs/035866691871/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:us-west-2:035866691871:trail/devops-security-tf-backend-logs"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "tf_backend_logs" {
  bucket = aws_s3_bucket.tf_backend_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// blocked_encryption_types is deliberately not set. The provider reads it back as
// ["SSE-C"] on both buckets but it is computed, so leaving it out produces no diff.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_logs" {
  bucket = aws_s3_bucket.tf_backend_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

// Only this bucket has ownership controls. The management-events bucket has none, and no
// equivalent resource is declared for it below -- declaring one would create it rather
// than import it, which is a live change.
resource "aws_s3_bucket_ownership_controls" "tf_backend_logs" {
  bucket = aws_s3_bucket.tf_backend_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

// The `project` tag already exists on this trail and has to be declared here. Without it
// the provider's default_tags would plan to REMOVE it, which is why this is the one
// resource in this file carrying a tags block.
resource "aws_cloudtrail" "tf_backend_logs" {
  name                          = "devops-security-tf-backend-logs"
  s3_bucket_name                = aws_s3_bucket.tf_backend_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  advanced_event_selector {
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.ARN"
      equals = ["arn:aws:s3:::hfla-ops-terraform-state/"]
    }
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
  }

  tags = {
    project = "devops-security"
  }
}

// ---------------------------------------------------------------------------
// management-events -- the account's management events
// ---------------------------------------------------------------------------

resource "aws_s3_bucket" "management_events" {
  bucket = "aws-cloudtrail-logs-035866691871-6539ef03"
}

// Verbatim from the live bucket, including the "AWS:SourceArn" spelling -- see the note on
// the policy above.
resource "aws_s3_bucket_policy" "management_events" {
  bucket = aws_s3_bucket.management_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck20150319"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::aws-cloudtrail-logs-035866691871-6539ef03"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-west-2:035866691871:trail/management-events"
          }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite20150319"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::aws-cloudtrail-logs-035866691871-6539ef03/AWSLogs/035866691871/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-west-2:035866691871:trail/management-events"
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "management_events" {
  bucket = aws_s3_bucket.management_events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "management_events" {
  bucket = aws_s3_bucket.management_events.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

// Log file validation is off on this trail and on for the other. That inconsistency is
// reproduced rather than resolved -- turning it on is a live change and its own ticket.
resource "aws_cloudtrail" "management_events" {
  name                          = "management-events"
  s3_bucket_name                = aws_s3_bucket.management_events.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = false

  advanced_event_selector {
    name = "Management events selector"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }
}
