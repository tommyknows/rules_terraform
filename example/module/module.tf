variable "x" {
}

output "y" {
  value = "${var.x} world!"
}
