variable "name" {
    default = "test"
}
variable "aws_region" {
    default = "ap-northeast-2"
}
variable "account_id" {
  default = ""
}
variable "source_ip" {
  default = ""
}
variable "subnets" {
  default = ["subnet-00000000", "subnet-11111111"]
}
variable "subnet_group_name" {
  default = "default"
}
variable "security_groups" {
  default = ["sg-1234567"]
}
variable "availability_zones" {
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "vpc" {
  default = "vpc-00000000"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}