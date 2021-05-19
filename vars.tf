variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}


variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "MyEFSkey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "MyEc2KeyPair.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
   # us-east-1 = "ami-13be557e"
    us-east-1 = "ami-0742b4e673072066f"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "my_aws_subnet" {
  type = map(string)
  default = {
    "us-east-1a" = "subnet-0bdf4983d2b0a4d64"
    "us-east-1b" = "subnet-0c4d87bfb468ccf1f"
    "us-east-1c" = "subnet-0cb81546bbc538fa4"  
    "us-east-1d" = "subnet-0cb669c82e02d5b4c"
    "us-east-1e" = "subnet-0bfc4104e921bbd60"
  }
}  

variable "USERNAME" {}
variable "DATABASE_NAME" {}
variable "DATABASE_PASSWORD" {}
#variable "SNAPSHOT_NAME"{}
#variable "FILE_SYSTEM_ID" {
  #default = "WordpressEFS"
#} 
#variable "SECURITY_GROUP" {
  #default= "sg-065ef1ecb1c932f66"
#}

#variable "PATH_TO_PRIVATE_KEY" {}

 #variable "RDS_PASSWORD" {
# }

#variable "INSTANCE_USERNAME" {
#}


