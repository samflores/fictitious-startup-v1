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

##############
# networking #
##############

module "networking" {
  source = "./modules/networking"

  vpc_cidr             = "172.16.0.0/16"
  public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnet_cidrs = ["172.16.3.0/24", "172.16.4.0/24"]
  availability_zones   = ["us-east-2a", "us-east-2b"]
}

#############
# computing #
#############

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }
}

module "computing" {
  source        = "./modules/computing"
  vpc_id        = module.networking.vpc_id
  subnet_id     = element(module.networking.public_subnet_ids, 0)
  instance_type = "t2.micro"
  ami_id        = data.aws_ami.ubuntu.id
}
