# This template is used by tf_download to generate a bulid file for a downlaoded
# terraform binary.
load("@rules_terraform//terraform:def.bzl", "terraform_toolchain")

terraform_toolchain(
    name = "toolchain_impl",
    binary = ":terraform",
)

# toolchain is a Bazel toolchain that expresses execution and target
# constraints for toolchain_impl. This target should be registered by
# calling register_toolchains in a WORKSPACE file.
toolchain(
    name = "toolchain",
    exec_compatible_with = [
        {exec_constraints},
    ],
    target_compatible_with = [
        {target_constraints},
    ],
    toolchain = ":toolchain_impl",
    toolchain_type = "@rules_terraform//terraform:toolchain_type",
)
