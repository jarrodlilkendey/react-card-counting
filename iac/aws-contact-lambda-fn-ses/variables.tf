variable "REGION" {
  type = string
}

variable "DOMAIN_NAME" {
  type = string
}

variable "FUNCTION_NAME" {
  type = string
}

variable "FROM_EMAIL"   {
  type = string
}

variable "TO_EMAIL" {
  type = string
}

variable "ALLOWED_ORIGINS" {
  type = list(string)
}