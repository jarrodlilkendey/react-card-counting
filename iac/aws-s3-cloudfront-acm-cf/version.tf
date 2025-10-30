terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=6.15.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.11.0"
    }
  }
}