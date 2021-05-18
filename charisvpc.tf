#CREATE VPC
resource "aws_vpc" "clixxappvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "clixxappvpc"
  }
}

#CREATE 2 PUBLIC SUBNETS, 6 PRIVATE SUBNETS
resource "aws_subnet" "PUB_CLIXXA" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.0.0/17"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PUB_CLIXXA"
  }
}

resource "aws_subnet" "PUB_CLIXXB" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.128.0/18"
  availability_zone = "us-east-1b"


  tags = {
    Name = "PUB_CLIXXB"
  }
}

resource "aws_subnet" "APP_PRIVA" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.192.0/19"
  availability_zone = "us-east-1a"

  tags = {
    Name = "APP_PRIVA"
  }
}

resource "aws_subnet" "APP_PRIVB" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.224.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "APP_PRIVB"
  }
}
resource "aws_subnet" "RDS_PRIVA" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.240.0/21"
  availability_zone = "us-east-1a"

  tags = {
    Name = "RDS_PRIVA"
  }
}

resource "aws_subnet" "RDS_PRIVB" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.248.0/22"
  availability_zone = "us-east-1b"

  tags = {
    Name = "RDS_PRIVB"
  }
}

resource "aws_subnet" "ORACLE_PRIVA" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.252.0/23"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ORACLE_PRIVA"
  }
}

resource "aws_subnet" "ORACLE_PRIVB" {
  vpc_id     = aws_vpc.clixxappvpc.id
  cidr_block = "10.0.254.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ORACLE_PRIVB"
  }
}

#CREATE PUBLIC SECURITY GROUPS
resource "aws_security_group" "PUBSGA" {
  name        = "PUBSGA"
  description = "Allow SSH and HTTP"
  vpc_id     = aws_vpc.clixxappvpc.id
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
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
    description      = "ICMP"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "loadbalancersga" {
  name        = "loadbalancersga"
  vpc_id     = aws_vpc.clixxappvpc.id
  ingress {
    description = "HTTP to load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "pubtoapp" {
  name        = "pubtoapp"
  vpc_id     = aws_vpc.clixxappvpc.id
  description = "sql gives ec2 permission to enter"
  ingress {
    description = "HTTP to load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.PUBSGA.id, aws_security_group.loadbalancersga.id]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.PUBSGA.id]
  }
  ingress {
    description      = "ICMP"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    security_groups = [aws_security_group.PUBSGA.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_security_group" "databasesg" {
  name        = "databasesg"
  vpc_id     = aws_vpc.clixxappvpc.id
  description = "oracle gives rds permission to enter"
  ingress {
    description = "MySQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.pubtoapp.id]
 }
} 
resource "aws_security_group" "rdstooracleb" {
  name        = "rdstooracleb"
  vpc_id     = aws_vpc.clixxappvpc.id
  description = "oracle gives rds permission to enter"
  /*ingress {
    description = "Oracle-RDS"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    security_groups = [aws_security_group.pubtoapp.id,aws_security_group.pubtoapp.id]
}*/
} 

#CREATE A DATABASE SUBNET GROUP
resource "aws_db_subnet_group" "dbsubnetgrp" {
  name        = "dbsubnetgrp"
  subnet_ids = [aws_subnet.RDS_PRIVA.id, aws_subnet.RDS_PRIVB.id]
}
#WAKE UP CLIXX APPLICATION SNAPSHOT
resource "aws_db_instance" "CustomClixxDB" {
  instance_class      = "db.t2.micro"
  snapshot_identifier = "clixxdbsnap"
  identifier = "clixxdbsnap"
  db_subnet_group_name = aws_db_subnet_group.dbsubnetgrp.id
  vpc_security_group_ids = [aws_security_group.pubtoapp.id,aws_security_group.databasesg.id]
  publicly_accessible= true
  skip_final_snapshot = true
}

#CREATE LAUNCH CONFIGURATION
resource "aws_launch_configuration" "customclixxas" { 
  name = "CUSTOMCLIXXCONFIG"
  image_id      = "ami-0742b4e673072066f"               
  instance_type = "t2.micro"
  #iam_instance_profile = aws_iam_instance_profile.s3_clixx_profile.name
  key_name = "clixxprivkey"
  security_groups = [aws_security_group.pubtoapp.id,] 
  #depends_on = [aws_db_instance.CustomClixxDB]
  #key_name      =  var.PATH_TO_PRIVATE_KEY                
  user_data = templatefile("customclixx.sh", {
    MOUNT_POINT = "/var/www/html",
    REGION = var.AWS_REGION,
    DB_NAME = var.DATABASE_NAME,
    USERNAME =var.USERNAME, 
    DB_PASSWORD = var.DATABASE_PASSWORD, 
    RDS_ENDPOINT = aws_db_instance.CustomClixxDB.address,
    #FILE_SYSTEM_ID = aws_efs_file_system.customclixxas.id,
    APP_LB = aws_lb.clixxapplb.dns_name

  #lifecycle {
    #create_before_destroy = true
  #}
    })
}

#CREATE AUTOSCALING GROUP FOR AVAILIBLITY ZONE A
resource "aws_autoscaling_group" "autocustomclixxa" {
  launch_configuration  = aws_launch_configuration.customclixxas.name
  target_group_arns = [aws_lb_target_group.lbtarget.arn]
  name_prefix        = "clixxzonea-"
  #availability_zones = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e"]
  vpc_zone_identifier= [aws_subnet.APP_PRIVA.id, aws_subnet.APP_PRIVB.id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true

  tag {
    key                 = "Name"
    value               = "autocustomclixxa"
    propagate_at_launch = true
  }
}

#CREATE APPLICATION LOAD BALANCER ATTACHMENT
resource "aws_autoscaling_attachment" "attachclixxa" {
  autoscaling_group_name = aws_autoscaling_group.autocustomclixxa.id
  alb_target_group_arn   = aws_lb_target_group.lbtarget.arn
}
/*
#CREATE TWO AUTOSCALING GROUPS FOR EACH AVAILIBLITY ZONE
resource "aws_autoscaling_group" "autocustomclixxb" {
  launch_configuration  = aws_launch_configuration.customclixxas.name
  name_prefix        = "clixxzoneb-"
  #availability_zones = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e"]
  vpc_zone_identifier       = [aws_subnet.APP_PRIVB.id]
  target_group_arns = [ aws_lb_target_group.lbtarget.arn ]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true

  tag {
    key                 = "Name"
    value               = "autocustomclixxb"
    propagate_at_launch = true
  }
}

#CREATE APPLICATION LOAD BALANCER ATTACHMENT
resource "aws_autoscaling_attachment" "attachclixxb" {
  autoscaling_group_name = aws_autoscaling_group.autocustomclixxb.id
  alb_target_group_arn   = aws_lb_target_group.lbtarget.arn
}
*/
#CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "CLIXXIG" {
  vpc_id = aws_vpc.clixxappvpc.id

  tags = {
    Name = "CLIXXIG"
  }
}
#CREATE ROUTE TABLE FOR INTERNET GATEWAY
resource "aws_route_table" "IGROUTER" {
  vpc_id = aws_vpc.clixxappvpc.id
  depends_on = [aws_internet_gateway.CLIXXIG]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.CLIXXIG.id
  }

  tags = {
    Name = "IGROUTER"
  }
}
#ASSOCIATE ROUTE TABLE WITH INTERNET GATEWAY
resource "aws_route_table_association" "IGROUTER1A" {
  subnet_id = aws_subnet.PUB_CLIXXA.id
  route_table_id = aws_route_table.IGROUTER.id
}

#ASSOCIATE ROUTE TABLE WITH INTERNET GATEWAY SECOND PUBLIC SUBNET
resource "aws_route_table_association" "IGROUTER1B" {
  subnet_id = aws_subnet.PUB_CLIXXB.id
  route_table_id = aws_route_table.IGROUTER.id
}

#CREATE ELASTIC IP AND ASSOCIATE IT WITH NAT GATEWAY
resource "aws_eip" "nat_eip" {
  vpc                       = true
  depends_on = [aws_internet_gateway.CLIXXIG]
}

#CREATE NAT GATEWAY
resource "aws_nat_gateway" "NATCLIXXA" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.PUB_CLIXXA.id
  depends_on = [aws_internet_gateway.CLIXXIG]

  tags = {
    Name = "NATCLIXXA"
  }
}

#CREATE ROUTE TABLE FOR NAT GATEWAY
resource "aws_route_table" "NATROUTER" {
  vpc_id = aws_vpc.clixxappvpc.id
  depends_on = [aws_internet_gateway.CLIXXIG]

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATCLIXXA.id
  }

  tags = {
    Name = "NATROUTER"
  }
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natappa" {
  subnet_id = aws_subnet.APP_PRIVA.id
  route_table_id = aws_route_table.NATROUTER.id
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natappb" {
  subnet_id = aws_subnet.APP_PRIVB.id
  route_table_id = aws_route_table.NATROUTER.id
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natrdsa" {
  subnet_id = aws_subnet.RDS_PRIVA.id
  route_table_id = aws_route_table.NATROUTER.id
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natrdsb" {
  subnet_id = aws_subnet.RDS_PRIVB.id
  route_table_id = aws_route_table.NATROUTER.id
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natoraclea" {
  subnet_id = aws_subnet.ORACLE_PRIVA.id
  route_table_id = aws_route_table.NATROUTER.id
}
#ASSOCIATE ROUTE TABLE WITH NAT GATEWAY
resource "aws_route_table_association" "natoracleb" {
  subnet_id = aws_subnet.ORACLE_PRIVB.id
  route_table_id = aws_route_table.NATROUTER.id
}

#CREATE ELASTIC IP AND ASSOCIATE WITH BASTION SERVER
resource "aws_eip" "bastionip" {
  instance = aws_instance.bastion.id
  vpc      = true
}

#CREATE BASTION SERVER
resource "aws_instance" "bastion" {
  ami      = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.PUB_CLIXXA.id
  key_name = "MyEC2KeyPair"
  vpc_security_group_ids = [aws_security_group.PUBSGA.id]

  tags = {
    Name = "bastion"
  }
}
#CREATE APPLICATION LOAD BALANCER
resource "aws_lb" "clixxapplb" {
  name               = "clixxapplb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancersga.id,aws_security_group.loadbalancersga.id]
  subnets            = [aws_subnet.PUB_CLIXXA.id,aws_subnet.PUB_CLIXXB.id]

  enable_deletion_protection = false

  #access_logs {
    #bucket  = aws_s3_bucket.lb_logs.bucket
    #prefix  = "test-lb"
    #enabled = true
  #}

  tags = {
    Environment = "clixxapplb"
  }
}

#CREATE TARGET GROUP
resource "aws_lb_target_group" "lbtarget" {
  name     = "lbtarget"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.clixxappvpc.id
  health_check {
    path = "/index.php"  
  }
}

#CREATE LISTENER
resource "aws_lb_listener" "clixxlisten" {
  load_balancer_arn = aws_lb.clixxapplb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtarget.arn
  }
}