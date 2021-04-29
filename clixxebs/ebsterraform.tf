#CREATE AN EC2 INSTANCE w/BOOTSTRAP SCRIPT
resource "aws_instance" "EBSTerraform" {
  ami           =  var.AMIS["us-east-1"] #"ami-0742b4e673072066f"
  instance_type = "t2.micro"
  availability_zone = "us-east-1d"
  security_groups = [ "MyWebDMZ" ]
  user_data = file("clixxebs/EBSpartition.sh")
  /*user_data = templatefile("EBSBootstrap.sh", {
    var=,
    })*/
  key_name = "ebstestkey"
  tags = {
    Name = "TF-EBS"
  }
}
  
#CREATE EBS VOLUMES
resource "aws_ebs_volume" "u01" {
  availability_zone = "us-east-1d"
  size              = 8

  tags = {
    Name = "u01"
  }
}

resource "aws_ebs_volume" "u02" {
  availability_zone = "us-east-1d"
  size              = 8

  tags = {
    Name = "u02"
  }
}

resource "aws_ebs_volume" "u03" {
  availability_zone = "us-east-1d"
  size              = 8

  tags = {
    Name = "u03"
  }
}

resource "aws_ebs_volume" "u04" {
  availability_zone = "us-east-1d"
  size              = 8

  tags = {
    Name = "u04"
  }
}

#ATTACH EBS VOLUMES
resource "aws_volume_attachment" "ebs_u01" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.u01.id
  instance_id = aws_instance.EBSTerraform.id
  force_detach = true
}
resource "aws_volume_attachment" "ebs_u02" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.u02.id
  instance_id = aws_instance.EBSTerraform.id
  force_detach = true
}
resource "aws_volume_attachment" "ebs_u03" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.u03.id
  instance_id = aws_instance.EBSTerraform.id
  force_detach = true
}
resource "aws_volume_attachment" "ebs_u04" {
  device_name = "/dev/sde"
  volume_id   = aws_ebs_volume.u04.id
  instance_id = aws_instance.EBSTerraform.id
  force_detach = true
}
