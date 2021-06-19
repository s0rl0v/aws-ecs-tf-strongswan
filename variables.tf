variable "region" {
  type        = string
  description = "Region to deploy VPN"
  default     = "eu-central-1"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags"
  default = {
    "Terraform" = "true"
  }
}

variable "cidr" {
  type        = string
  description = "Default cidr for vpc"
  default     = "10.1.0.0/16"
}

variable "vpn_domain" {
  type        = string
  description = "Default VPN domain name"
  default     = "vpn.s0rl0v.com"
}
