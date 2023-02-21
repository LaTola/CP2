
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "ipconfig" {
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  })
}
