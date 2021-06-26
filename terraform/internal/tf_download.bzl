def _tf_download_impl(ctx):
    ctx.report_progress("downloading terraform binary")
    ctx.download_and_extract(
        ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        #stripPrefix = "go",
    )

    # Add a build file to the repository root directory.
    # We need to fill in some template parameters, based on the platform.
    ctx.report_progress("generating build file")
    if ctx.attr.os == "darwin":
        os_constraint = "@platforms//os:osx"
    elif ctx.attr.os == "linux":
        os_constraint = "@platforms//os:linux"
    elif ctx.attr.os == "windows":
        os_constraint = "@platforms//os:windows"
    else:
        fail("unsupported os: " + ctx.attr.os)
    if ctx.attr.arch == "amd64":
        arch_constraint = "@platforms//cpu:x86_64"
    else:
        fail("unsupported arch: " + ctx.attr.arch)
    constraints = [os_constraint, arch_constraint]
    constraint_str = ",\n        ".join(['"%s"' % c for c in constraints])

    substitutions = {
        "{os}": ctx.attr.os,
        "{arch}": ctx.attr.arch,
        "{exe}": ".exe" if ctx.attr.os == "windows" else "",
        "{exec_constraints}": constraint_str,
        "{target_constraints}": constraint_str,
    }
    ctx.template(
        "BUILD.bazel",
        ctx.attr._build_tpl,
        substitutions = substitutions,
    )

terraform_download = repository_rule(
    implementation = _tf_download_impl,
    attrs = {
        "urls": attr.string_list(
            mandatory = True,
            doc = "List of mirror URLs for a Terraform Binary archive",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "Expected SHA-256 sum of the downloaded archive",
        ),
        "os": attr.string(
            mandatory = True,
            values = ["darwin", "linux", "windows"],
            doc = "Host operating system for the terraform binary",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["amd64", "aarch64"],
            doc = "Host architecture for the terraform binary",
        ),
        "_build_tpl": attr.label(
            default = ":BUILD.binary.bzl",
        ),
    }
)
