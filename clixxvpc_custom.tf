#CREATE VPC
resource "aws_vpc" "clixxappvpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "clixxappvpc"
  }
}
