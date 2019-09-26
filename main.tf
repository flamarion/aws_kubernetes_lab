provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "~/.aws/creds"
  profile                 = "default"
  version                 = "~> 2.7"
}

provider "random" {
  version = "~> 2.0"
}
