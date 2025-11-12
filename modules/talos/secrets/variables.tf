variable "versions" {
  description = "Version matrix"
  type = object({
    talos = string
  })
  default = null
}

# Legacy scalar input (backward compatible)
variable "talos_version" {
  # https://github.com/siderolabs/talos/releases
  type    = string
  default = "1.11.5"
}
