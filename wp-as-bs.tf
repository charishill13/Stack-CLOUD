#CREATE AN EC2 INSTANCE w/BOOTSTRAP SCRIPT
resource "aws_instance" "wptefs1" {
  ami           = "ami-0742b4e673072066f" #var.AMIS["use-east-1"]
  instance_type = "t2.micro"
  user_data = file("${path.module}/eBootstrap.sh")
  #user_data = templatefile("BOOTSTRAP_w_EFS.sh", {
    #MOUNT_POINT = "/var/www/html",
    #REGION = var.AWS_REGION,
    #DB_NAME = var.DATABASE_NAME
    #DB_USER = var.USERNAMEterraform 
    #FILE_SYSTEM_ID = aws_efs_file_system.WordPressEFS.id})
  key_name = "MyEC2KeyPair"
  depends_on =[aws_efs_mount_target.mounthere]
  security_groups = [aws_security_group.wptefs_security.name]
    tags = {
      Name = "wptefs1"
  }
}

#CREATE SECURITY GROUP FOR EC2 INSTANCE w/ SSH, HTTP, EFS RULES
resource "aws_security_group" "wptefs_security" {
  name        = "wptefs_security"
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
  encrypted = true
  throughput_mode = "bursting"
  tags = {
    Name = "WordpressEFS"
  }
}

#CREATE EFS MOUNT TARGET
resource "aws_efs_mount_target" "mounthere" {
  depends_on = [aws_efs_file_system.WordpressEFS]
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id = var.my_aws_subnet["us-east-1d"]
  security_groups = [aws_security_group.wptefs_security.id]
}

#CREATE EFS MOUNT POINT
resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.mounthere]
connection {
type     = "ssh"
user     = "ec2-user"
#private_key = tls_private_key.pritf_key.private_key_pem
host     = aws_instance.wptefs1.public_ip
 }
}

#CREATE EFS MOUNT Target
#resource "aws_efs_mount_target" "gohere" {
  #file_system_id = aws_efs_file_system.WordpressEFS.id
  #subnet_id = var.my_aws_subnet["us-east-1e"]
#}



#GENERATE PRIVATE KEY
#resource "tls_private_key" "pritf_key" {
#algorithm = "RSA"
#}

#GENERATE KEY PAIR WITH PREVIOUSLY CREATED KEY
#resource "aws_key_pair" "tf_key_pair" {
  #key_name   = "tf_efs_key"
  #public_key = tls_private_key.pritf_key.public_key_openssh
#}

#SAVE KEYPAIR FOR SSH CLIENT LOGIN
#resource "null_resource" "save_key_pair"  {
  #provisioner "local-exec" {
  #command = "echo  ${tls_private_key.pritf_key.private_key_pem} > mykey.pem"
#}
#}

#CREATE LAUNCH CONFIGURATION
resource "aws_launch_configuration" "WordPressEFS1" {
  name          = "wpefs_launch_config"
  image_id      = "ami-0742b4e673072066f"                ##"var.AMIS[us-east-1]"
  instance_type = "t2.micro"
  key_name      =  var.PATH_TO_PRIVATE_KEY               ##var.PATH_TO_PRIVATE_KEY##
  security_groups = ["wptefs_security"]
  user_data = file("${path.module}/eBootstrap.sh")
  #user_data = templatefile("BOOTSTRAP_w_EFS.sh", {
    #MOUNT_POINT = "/var/www/html",
    #REGION = var.AWS_REGION,
    #DB_NAME = var. DATABASE_NAME
    #DB_USER = var.USERNAME
    #FILE_SYSTEM_ID = aws_efs_file_system.WordpressEFS
    #depends_on = [aws_efs_mount_target.mounthere]})  
}
#CREATE AUTOSCALING GROUP
resource "aws_autoscaling_group" "WPEFS1" {
  launch_configuration  = aws_launch_configuration.WordPressEFS1.name
  availability_zones = ["us-east-1d"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  force_delete       = true

  }
