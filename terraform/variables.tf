variable "owner" {
  description = "Name or handle of the owner for this resource. Used for tagging resources."
}

variable "prefix" {
  description = "Prefix to put on resources names for better identification. Initials work great here."
}

variable "ssh_public_key" {
  description = "Your ssh public key used to ssh into resources."
}
