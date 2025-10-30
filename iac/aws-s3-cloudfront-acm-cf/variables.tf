variable "REGION" {
  type = string
}

variable "DOMAIN_NAME" {
  type = string
}

variable "CLOUDFLARE_API_TOKEN" {
  type = string
  sensitive = true
}