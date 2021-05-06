#CREATE SECURITY GROUP FOR EC2 INSTANCE w/ SSH, HTTP, EFS RULES
resource "aws_security_group" "secure_clixxapp" {
  name        = "secure_clixxapp"
  description = "Allow SSH and HTTP"
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MYSQL from VPC"
    from_port   = 3306
    to_port     = 3306
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
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
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
resource "aws_efs_file_system" "wordpressclixx" {
  throughput_mode = "bursting"
  tags = {
    Name = "wordpressclixx"
  }
}

#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "amounthere" {
  file_system_id = aws_efs_file_system.wordpressclixx.id
  subnet_id = var.my_aws_subnet["us-east-1a"]
  security_groups = [aws_security_group.secure_clixxapp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "bmounthere2" {
  file_system_id = aws_efs_file_system.wordpressclixx.id
  subnet_id = var.my_aws_subnet["us-east-1b"]
  security_groups = [aws_security_group.secure_clixxapp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "cmounthere" {
  file_system_id = aws_efs_file_system.wordpressclixx.id
  subnet_id = var.my_aws_subnet["us-east-1c"]
  security_groups = [aws_security_group.secure_clixxapp.id]
}
#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "dmounthere" {
  file_system_id = aws_efs_file_system.wordpressclixx.id
  subnet_id = var.my_aws_subnet["us-east-1d"]
  security_groups = [aws_security_group.secure_clixxapp.id]
}

#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "emounthere" {
  file_system_id = aws_efs_file_system.wordpressclixx.id
  subnet_id = var.my_aws_subnet["us-east-1e"]
  security_groups = [aws_security_group.secure_clixxapp.id]
}
#WAKE UP CLIXX APPLICATION SNAPSHOT
resource "aws_db_instance" "restore" {
  instance_class      = "db.t2.micro"
  name                = ""
  snapshot_identifier = "clixxdbsnap"
  availability_zone   = "us-east-1d"
  vpc_security_group_ids = [aws_security_group.secure_clixxapp.id]
  publicly_accessible= true
  skip_final_snapshot = true
}

#CREATE LAUNCH CONFIGURATION
resource "aws_launch_configuration" "WordPressClixx" {
  name = "wordpressdbclixx"
  image_id      = "ami-0742b4e673072066f"                ##"var.AMIS[us-east-1]"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.s3_clixx_profile.name
  key_name = "MyEC2KeyPair"
  security_groups = [aws_security_group.secure_clixxapp.id] 
  depends_on = [aws_db_instance.restore]
  #key_name      =  var.PATH_TO_PRIVATE_KEY                
  user_data = templatefile("wp-as-bsclixx.sh", {
    MOUNT_POINT = "/var/www/html",
    REGION = var.AWS_REGION,
    DB_NAME = var.DATABASE_NAME,
    USERNAME =var.USERNAME, 
    DB_PASSWORD = var.DATABASE_PASSWORD, 
    RDS_ENDPOINT = aws_db_instance.restore.address,
    FILE_SYSTEM_ID = aws_efs_file_system.wordpressclixx.id,
    })
}

#CREATE S3 POLICY
resource "aws_iam_policy" "clixxpolicy" {
    name        = "s3_clixx_policy"
    description = "s3 admin access clixxpolicy"

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
resource "aws_iam_role" "clixxapprole" {
    name = "clixxapprole"
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
resource "aws_iam_policy_attachment" "s3_attach_clixx" {
    name       = "s3-attachment-clixx"
    policy_arn = aws_iam_policy.clixxpolicy.arn
    roles       =  [aws_iam_role.clixxapprole.name]
} 

#CREATE EC2 INTANCE WITH PROFILE ROLE
resource "aws_iam_instance_profile" "s3_clixx_profile" {
    name = "s3_clixx_profile"
    role = aws_iam_role.clixxapprole.name
}

#CREATE AUTOSCALING GROUP
resource "aws_autoscaling_group" "WordPressClixx" {
  launch_configuration  = aws_launch_configuration.WordPressClixx.name
  name_prefix        = "clixxapp-as-"
  #availability_zones = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e"]
  availability_zones = ["us-east-1d"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true
  #lifecycle {
    #create_before_destroy = true
}




