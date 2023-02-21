variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "computer_name" {
  type = string
}
variable "os_disk_name" {
  type = string
}

variable "nic_ids" {
  type = list(string)
}

variable "admin_username" {
  type = string
}

variable "public_key" {
  type = string
}


