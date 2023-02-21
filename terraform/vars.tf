variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "public_key" {
  type = string
}

variable "network_cidr" {
  type = list(string)
}

variable "subnet_cidr" {
  type = list(string)
}

