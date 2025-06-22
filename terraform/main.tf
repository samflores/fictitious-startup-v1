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

  owners = ["099720109477"]
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

module "computing" {
  source                 = "./modules/computing"
  vpc_id                 = module.networking.vpc_id
  subnet_id              = element(module.networking.public_subnet_ids, 0)
  instance_type          = "t2.micro"
  ami_id                 = data.aws_ami.ubuntu.id
  instance_profile_names = [aws_iam_instance_profile.ssm_profile.name]
}

#############
# database  #
#############

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

module "database" {
  source            = "./modules/database"
  password          = var.db_password
  username          = var.db_username
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  subnet_group_name = "bootcamp_db_subnet_group"
}
