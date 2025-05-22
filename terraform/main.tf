terraform {
  backend "s3" {
    bucket       = "codeminer-aws-bootcamp-deployment-packages"
    key          = "terraform/state"
    region       = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr             = "172.16.0.0/16"
  public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnet_cidrs = ["172.16.3.0/24", "172.16.4.0/24"]
  availability_zones   = ["us-east-2a", "us-east-2b"]
}
