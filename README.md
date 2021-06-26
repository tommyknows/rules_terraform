# Terraform rules for [Bazel](https://bazel.build/)

## Contents

- [Overview](#overview)
- [Setup](#setup)
- [Rules](#rules)
  - [`terraform_module`](#terraform_module)
  - [`terraform_toolchain`](#terraform_toolchain)
- [Supported Versions](#supported-versions)
- [State Management](#state-managemnt)
- [Terraform Providers](#terraform-providers)
- [Examples](#examples)

## Overview

`rules_terraform` are Bazel rules for running [terraform](https://terraform.io)
as part of your build workflow. These rules currently support grouping files in
a directory as a module, as well as planning & applying these modules.

## Setup

```bzl
git_repository(
    name = "io_bazel_rules_terraform",
    commit = "<latest commit sha>",
    remote = "https://github.com/tommyknows/rules_terraform",
)

load("@io_bazel_rules_terraform//terraform:deps.bzl", "terraform_dependencies")

terraform_dependencies(version = "1.0.1")
```

## Rules

### `terraform_module`

`terraform_module` can be used to create a single terraform module.

*Attributes*:

- `srcs`: a list of files that make up this module. All files should be in the
    same directory.
- `modules`: a list of other `terraform_modules` that are used within this
    module.

This rule / macro creates three targets:

- `<target-name>`: a simple wrapper for modules
- `<target-name>.apply`: target to run `terraform apply` on this module.
    Executable through `bazel run //<target-name>.apply`
- `<target-name>.plan`: target to run `terraform plan` on this module.
    Executable through `bazel run //<target-name>.plan`

### `terraform_toolchain`

The `terraform_toolchain` rule can be used to register a custom binary for
terraform. There is a single attribute `binary`, which needs to be executable on
the host.

Usually, this rule shouldn't be used, and specific version should be specified
through the `terraform_dependencies` instead.

## Supported Versions

In general, all version of terraform are supported through the `version`
parameter in `terraform_dependencies`. However, most versions will require the
user to specify a sha256 sum to `terraform_dependencies`, like so:

```bzl
terraform_dependencies(
    version = "1.0.0",
    sha256 = ""
)
```

This sha256 sum is the digest of the SHA256 checksum file from terraform, which
is then in turn used to download the terraform binaries and verify their
checksums.

This file can be found at Terraform's [download page](https://www.terraform.io/downloads.html)

Pull Requests that add new versions & their digests are highly welcome!

## State Management

State management cannot be done through Bazel - the state file would be an input
and output to a build action, which is a cyclic dependency - and needs to be
done by a [remote state](https://www.terraform.io/docs/language/state/remote.html).

## Terraform Providers

Currently, terraform providers cannot be fetched through these rules. However,
it is highly recommended to use the official [Provider Requirements](https://www.terraform.io/docs/language/providers/requirements.html)
instead.

## Examples

See the [examples](./examples) directory for a simple example on how to use
these rules.
