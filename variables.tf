variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region"
  default     = {}
}