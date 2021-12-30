
variable "main_vpc_cidr" {
  description = "The CIDR of the main VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR of public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR of the private subnet"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "tag_name" {
  description = "A name used to tag the resource"
  type        = string
  default     = "terraform-network-example"
}

variable "network_acl_id" {
  description = "the aws network acl"
  type = string
}