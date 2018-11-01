provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "~/.aws/creds"
  profile                 = "default"
  version                 = "~> 1.42"
}

provider "random" {
  version = "~> 2.0"
}
