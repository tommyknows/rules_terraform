variable "x" {
  default = "hello"
}

module "m" {
  source = "./module"
  x      = var.x
}

output "y" {
  value = module.m.y
}
