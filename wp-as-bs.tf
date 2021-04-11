#CREATE ELASTIC FILE SYSTEM
resource "aws_efs_file_system" "WordpressEFS" {
  tags = {
    Name = "WordpressEFS"
  }
}
#CREATE EFS MOUNT POINT IN 
resource "aws_efs_mount_target" "mountpoint" {
  file_system_id = aws_efs_file_system.WordpressEFS.id
  subnet_id      = aws_subnet.mountpoint.id
}
#CREATE SUBNETS FOR EFS
resource "aws_subnet" "east1a" {
  vpc_id            = aws_vpc.east1a.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "east1b" {
  vpc_id            = aws_vpc.east1b.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "east1c" {
  vpc_id            = aws_vpc.east1c.id
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "east1d" {
  vpc_id            = aws_vpc.east1d.id
  availability_zone = "us-east-1d"
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "east1e" {
  vpc_id            = aws_vpc.east1e.id
  availability_zone = "us-east-1e"
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "east1f" {
  vpc_id            = aws_vpc.east1f.id
  availability_zone = "us-east-1f"
  cidr_block        = "10.0.1.0/24"
}

#CREATE AUTOSCALING GROUP
#CREATE AN EC2 INSTANCE w/BOOTSTRAP SCRIPT

