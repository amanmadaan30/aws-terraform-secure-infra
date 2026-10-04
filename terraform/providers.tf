terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

provider "aws" {
  region                   = "ap-southeast-2"
  shared_credentials_files = ["C:/Users/HP/.aws/credentials"]
  profile                  = "am_tf_vscode"
  shared_config_files      = ["C:/Users/HP/.aws/config"]
}
