region-name              = "ap-northeast-2"
vpc-cidr-block           = "10.0.0.0/16"
vpc-name                 = "three-tier-vpc"
igw-name                 = "three-tier-igw"
nat-gw-name1              = "three-tier-nat-gw1"
nat-gw-name2              = "three-tier-nat-gw2"

public-subnet1-cidr         = "10.0.1.0/24"
public-subnet1-name         = "three-tier-public-subnet1"
public-subnet2-cidr         = "10.0.2.0/24"
public-subnet2-name         = "three-tier-public-subnet2"

# WEB
web-subnet1-cidr         = "10.0.3.0/24"
web-subnet1-name         = "three-tier-web-subnet-1"
web-subnet2-cidr         = "10.0.4.0/24"
web-subnet2-name         = "three-tier-web-subnet-2"

az-1                     = "ap-northeast-2a"
az-2                     = "ap-northeast-2c"
public-rt-name           = "three-tier-public-route-table"
private-rt-name1         = "three-tier-private-route-table1"
private-rt-name2         = "three-tier-private-route-table2"

launch-template-web-name = "three-tier-launch-template-web"
image-id                 = "ami-04c596dcf23eb98d8" # 최신 amazon linux2 ami-id
instance-type            = "t2.micro"

web-instance-name        = "three-tier-web-instances"
alb-web-name             = "three-tier-alb-web"
alb-sg-web-name          = "three-tier-alb-sg-web"
asg-web-name             = "three-tier-asg-web"
asg-sg-web-name          = "three-tier-asg-sg-web"
tg-web-name              = "three-tier-tg-web"
