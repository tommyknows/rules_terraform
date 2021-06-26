def _tf_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        binary = ctx.file.binary,
    )]

terraform_toolchain = rule(
    implementation = _tf_toolchain_impl,
    attrs = {
        "binary": attr.label(
            mandatory = True,
            executable = True,
            allow_single_file = True,
            cfg = "host",
            doc = "Terraform executable",
        ),
    }
)
