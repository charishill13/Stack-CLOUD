#CREATE SECURITY GROUP FOR EC2 INSTANCE w/ SSH, HTTP, EFS RULES
resource "aws_security_group" "secure_efswp" {
  name        = "secure_efswp"
  description = "Allow SSH and HTTP"
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#CREATE ELASTIC FILE SYSTEM
resource "aws_efs_file_system" "WordpressEFS" {
  throughput_mode = "bursting"
  tags = {
    Name = "WordpressEFS"
  }
}
/*
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "amounthere" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1a"]
  security_groups = [aws_security_group.secure_efswp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "bmounthere2" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1b"]
  security_groups = [aws_security_group.secure_efswp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "cmounthere" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1c"]
  security_groups = [aws_security_group.secure_efswp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "dmounthere" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1d"]
  security_groups = [aws_security_group.secure_efswp.id]
}

#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "emounthere" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1e"]
  security_groups = [aws_security_group.secure_efswp.id]
}
*/
#CREATE LAUNCH CONFIGURATION
resource "aws_launch_configuration" "WordPressEFS1" {
  name_prefix   = "wpefs-lc-"
  image_id      = "ami-0742b4e673072066f"                ##"var.AMIS[us-east-1]"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.s3_profile.name
  security_groups = [aws_security_group.secure_efswp.name]
  key_name = "MyEC2KeyPair"
  #key_name      =  var.PATH_TO_PRIVATE_KEY                
  user_data = templatefile("wordpressuserdata.sh", {
    MOUNT_POINT = "/var/www/html",
    REGION = var.AWS_REGION,
    DB_NAME = var.DATABASE_NAME,
    DB_PASSWORD = var.DATABASE_PASSWORD,
    MYSQL_PASS=var.MYSQL_PASS,
    MYSQL_USER=var.MYSQL_USER,
    RDS_ENDPOINT = var.RDS_ENDPOINT,
    FILE_SYSTEM_ID = aws_efs_file_system.WordpressEFS.id
    })
  }

#CREATE S3 POLICY
resource "aws_iam_policy" "policy" {
    name        = "s3_policy"
    description = "s3 admin access policy"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "*" 
        }
    ]
}
    EOF
} 

#CREATE S3 ROLE 
resource "aws_iam_role" "s3_role" {
    name = "s3-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
    EOF 
}

#ATTACH POLICY TO S3 ROLE
resource "aws_iam_policy_attachment" "s3_attach" {
    name       = "s3-attachment"
    policy_arn = aws_iam_policy.policy.arn
    roles       =  [aws_iam_role.s3_role.name]
} 

#CREATE EC2 INTANCE WITH PROFILE ROLE
resource "aws_iam_instance_profile" "s3_profile" {
    name = "s3_profile"
    role = aws_iam_role.s3_role.name
}

#CREATE AUTOSCALING GROUP
resource "aws_autoscaling_group" "WPEFS1" {
  launch_configuration  = aws_launch_configuration.WordPressEFS1.name
  name_prefix        = "wordpress-as-"
  availability_zones = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true
  #lifecycle {
    #create_before_destroy = true
}

