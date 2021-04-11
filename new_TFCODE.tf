#Create S3 Bucket to (you'll host the website from here, with get/read access to website from policy)
resource "aws_s3_bucket" "WebsiteBuck" {
  bucket = "stacks3-charis"
  acl    = "public-read"
  policy = file("Buck1-policy.json")
  force_destroy = true

#Static Website Hosting
  website {
    index_document = "index.html"
    error_document = "error.html"
    #redirect_all_requests_to="www.google.com"
  }

#Enable Versioning
  versioning {
    enabled = true
  }

#Enable default server side encryption
server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

#Enable Logging
  logging {
    target_bucket = aws_s3_bucket.owologs.id
    target_prefix = "log/"
  }

#Enable Acceleration
  acceleration_status = "Enabled"
  tags = {
    Name        = "Main-Bucket"
    Environment = "Test"
  } 
} 

#Enable Logging to capture server access
resource "aws_s3_bucket" "owologs" {
  bucket = "owologbuck20"
  acl    = "log-delivery-write"
  force_destroy = true
}

#Enable Object Level Logging
resource "aws_cloudtrail" "website" {
  name = "owonikokotrails"
  s3_bucket_name = "cloudtrailowonikoko"

#Enable multi-region trail
  is_multi_region_trail = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  
#Data resource pulled from "data WebDataBuck"
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${data.aws_s3_bucket.WebDataBuck.arn}/"]
    }
  }
}
#Use data from this bucket for cloudtrail log
data "aws_s3_bucket" "WebDataBuck" {
  bucket = "stacks3-charis"
  depends_on = [
    aws_s3_bucket.WebsiteBuck,
  ]
}

#Create SNS Topic
resource "aws_sns_topic" "owoweb" {
  name = "owoweb-s3-event"
  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:owoweb-s3-event",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.owoevents.arn}"}
        }
    }]
}
POLICY
}

#Create bucket for event configuration
resource "aws_s3_bucket" "owoevents" {
  bucket = "web-owo-events"
  force_destroy = true
}
#add SNS Notification created bucket
resource "aws_s3_bucket_notification" "owonotifications" {
    bucket = aws_s3_bucket.owoevents.id
    topic {
      topic_arn     = aws_sns_topic.owoweb.arn
      events        = ["s3:ObjectCreated:*"]
      filter_suffix = ".log"
    }
}

#Enable Object Lock
resource "aws_s3_bucket" "otherfeatures" {
  bucket = "otherfeats"
  acl    = "private"
  force_destroy = true
object_lock_configuration {
    object_lock_enabled = "Enabled"
  }
}

#Upload Files to Bucket
resource "aws_s3_bucket_object" "index1" {
  bucket = "stacks3-charis"
  key    = "index.html"
  acl="public-read"
  source = "C:/Apps/Terraform/TF/STACK-S3-TF/src/main/tf/index.html"
   depends_on = [
    aws_s3_bucket.WebsiteBuck,
  ]
}

resource "aws_s3_bucket_object" "error" {
  bucket = "stacks3-charis"
  key    = "404.html"
  acl="public-read"
  source = "C:/Apps/Terraform/TF/STACK-S3-TF/src/main/tf/404.html"
   depends_on = [
    aws_s3_bucket.WebsiteBuck,
  ]
}

resource "aws_s3_bucket_object" "hiccups" {
  bucket = "stacks3-charis"
  key    = "stop-hiccups.png"
  acl="public-read"
  source = "C:/Apps/Terraform/TF/STACK-S3-TF/src/main/tf/stop-hiccups.png"
   depends_on = [
    aws_s3_bucket.WebsiteBuck,
  ]
}

resource "aws_s3_bucket_object" "owostyle" {
  bucket = "stacks3-charis"
  key    = "styles.css"
  acl="public-read"
  source = "C:/Apps/Terraform/TF/STACK-S3-TF/src/main/tf/styles.css"
  depends_on = [
    aws_s3_bucket.WebsiteBuck,
  ]
}


