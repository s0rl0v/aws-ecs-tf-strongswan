
data "aws_availability_zones" "available" {
  state = "available"
}

module "cidrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.cidr
  networks = [
    {
      name     = data.aws_availability_zones.available.names[0],
      new_bits = 8
    }
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "vpc-strongswan"
  cidr = var.cidr

  azs            = keys(module.cidrs.network_cidr_blocks)
  public_subnets = values(module.cidrs.network_cidr_blocks)

  enable_nat_gateway = false

  tags = var.default_tags
}
