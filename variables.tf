variable "region-name" {
  description = "Region name"
}
variable "vpc-cidr-block" {
  description = "CIDR Block for VPC"
}

variable "vpc-name" {
  description = "Name for Virtual Private Cloud"
}

variable "igw-name" {
  description = "Name for Internet Gateway"
}

variable "nat-gw-name1" {
  description = "Name for NAT Gateway1"
}
variable "nat-gw-name2" {
  description = "Name for NAT Gateway2"
}

variable "public-subnet1-cidr" {
  description = "CIDR Block for Web-tier Subnet-1"
}

variable "public-subnet1-name" {
  description = "Name for Web-tier Subnet-1"
}

variable "public-subnet2-cidr" {
  description = "CIDR Block for Web-tier Subnet-2"
}

variable "public-subnet2-name" {
  description = "Name for Web-tier Subnet-2"
}


## WEB
variable "web-subnet1-cidr" {
  description = "CIDR Block for Application-tier Subnet-1"
}

variable "web-subnet1-name" {
  description = "Name for app-tier Subnet-1"
}

variable "web-subnet2-cidr" {
  description = "CIDR Block for Application-tier Subnet-2"
}

variable "web-subnet2-name" {
  description = "Name for Application-tier Subnet-2"
}

variable "az-1" {
  description = "Availabity Zone 1"
}

variable "az-2" {
  description = "Availabity Zone 2"
}

variable "public-rt-name" {
  description = "Name for Public Route table"
}

variable "private-rt-name1" {
  description = "Name for Private Route table1"
}
variable "private-rt-name2" {
  description = "Name for Private Route table2"
}

variable "launch-template-web-name" {
  description = "Name for Launch-template-1"
}

variable "image-id" {
  description = "Value for Image-id"
}

variable "instance-type" {
  description = "Value for Instance type"
}

variable "web-instance-name" {
  description = "Value for Web Instances"
}

variable "alb-web-name" {
  description = "Name the Load Balancer for the Web Tier"
}

variable "alb-sg-web-name" {
  description = "Name for alb security group 1"
}

variable "asg-web-name" {
  description = "Name the Auto Scaling group in Web Tier"
}

variable "asg-sg-web-name" {
  description = "Name for asg security group 1"
}

variable "tg-web-name" {
  description = "Name for Target group web"
}
