load(
    "//terraform/internal:module.bzl",
    _terraform_module = "terraform_module",
)
load(
    "//terraform/internal:toolchain.bzl",
    _terraform_toolchain = "terraform_toolchain",
)

terraform_module = _terraform_module
terraform_toolchain = _terraform_toolchain
