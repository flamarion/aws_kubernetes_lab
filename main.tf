provider "aws" {
  region                  = "${var.aws_region}"
  version                 = "~> 2.7"
}

provider "random" {
  version = "~> 2.0"
}
