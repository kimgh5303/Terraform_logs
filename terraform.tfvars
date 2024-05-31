region-name              = "ap-northeast-2"
vpc-cidr-block           = "10.1.0.0/16"
vpc-name                 = "log-vpc"
igw-name                 = "log-igw"
nat-gw-name1              = "log-nat-gw1"
nat-gw-name2              = "log-nat-gw2"

public-subnet1-cidr         = "10.1.1.0/24"
public-subnet1-name         = "log-public-subnet1"
public-subnet2-cidr         = "10.1.2.0/24"
public-subnet2-name         = "log-public-subnet2"

# WEB
web-subnet1-cidr         = "10.1.3.0/24"
web-subnet1-name         = "log-web-subnet-1"
web-subnet2-cidr         = "10.1.4.0/24"
web-subnet2-name         = "log-web-subnet-2"

az-1                     = "ap-northeast-2a"
az-2                     = "ap-northeast-2c"
public-rt-name           = "log-public-route-table"
private-rt-name1         = "log-private-route-table1"
private-rt-name2         = "log-private-route-table2"

launch-template-web-name = "log-launch-template-web"
image-id                 = "ami-04c596dcf23eb98d8" # 최신 amazon linux2 ami-id
instance-type            = "t2.micro"

web-instance-name        = "log-web-instances"
alb-web-name             = "log-alb-web"
alb-sg-web-name          = "log-alb-sg-web"
asg-web-name             = "log-asg-web"
asg-sg-web-name          = "log-asg-sg-web"
tg-web-name              = "log-tg-web"
