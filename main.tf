provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

##### Backend infrastructure needed to be provision

resource "aws_security_group" "InstanceSecurityGroup" {
  name        = "ecommerence-${var.ID}"
  description = "Allow port 22"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}

resource "aws_instance" "EC2Instance" {
  ami           = "ami-0cb4e786f15603b0d" # Change this to your desired AMI
  instance_type = "t2.micro"
  key_name      = "ecommerence-key"            # Change this to your key pair name

  security_groups = [aws_security_group.InstanceSecurityGroup.name]

  tags = {
    Name = "backend-${var.ID}"
  }
}


##### FrontEnd CloudFormation infra 

resource "aws_cloudfront_origin_access_identity" "CloudFrontOriginAccessIdentity" {
  comment = "Origin Access Identity for Serverless Static Website"
}

resource "aws_cloudfront_distribution" "WebpageCDN" {
  origin {
    domain_name = "ecommerence-${var.WorkflowID}.s3.amazonaws.com"
    origin_id   = "webpage"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.CloudFrontOriginAccessIdentity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    forwarded_values {
      query_string = false
    }
    target_origin_id    = "webpage"
    viewer_protocol_policy = "allow-all"
  }
}

output "WorkflowID" {
  value = var.WorkflowID
  description = "URL for website hosted on S3"
  export {
    name = "WorkflowID"
  }
}

variable "WorkflowID" {}


########## FrontEnd S3 bucket

resource "aws_s3_bucket" "WebsiteBucket" {
  bucket = "ecommerence-${var.ID}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_policy" "WebsiteBucketPolicy" {
  bucket = aws_s3_bucket.WebsiteBucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.WebsiteBucket.arn}/*"
      }
    ]
  })
}

output "WebsiteURL" {
  value       = aws_s3_bucket.WebsiteBucket.website_endpoint
  description = "URL for the website hosted on S3"
}

variable "ID" {}
