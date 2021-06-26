def _tf_download_sumfile_impl(ctx):
    ctx.report_progress("downloading sumfile")
    ctx.download(
        url = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_SHA256SUMS".format(version = ctx.attr.version),
        sha256 = ctx.attr.sha256,
        output = "sumfile",
    )
    ctx.template(
        "BUILD.bazel",
        ctx.attr._sumfile_tpl,
    )

terraform_download_sumfile = repository_rule(
    implementation = _tf_download_sumfile_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(
            default = "",
        ),
        "_sumfile_tpl": attr.label(
            allow_single_file = True,
            default = ":BUILD.sumfile.bzl",
        )
    }
)

def _tf_download_impl(ctx):
    ctx.report_progress("reading sumfile")
    for sha in ctx.read(ctx.attr.sumfile).split("\n"):
        if sha.endswith("terraform_{version}_{os}_{arch}.zip".format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)):
            shasum = sha.split(" ", 2)[0]

    ctx.report_progress("downloading terraform binary")
    ctx.download_and_extract(
        url = ["https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{os}_{arch}.zip".format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)],
        sha256 = shasum
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
    elif ctx.attr.arch == "arm64":
        arch_constraint = "@platforms//cpu:aarch64"
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
        "version": attr.string(
            mandatory = True,
        ),
        "os": attr.string(
            mandatory = True,
            values = ["darwin", "linux", "windows"],
            doc = "Host operating system for the terraform binary",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["amd64", "arm64"],
            doc = "Host architecture for the terraform binary",
        ),
        "sumfile": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "_build_tpl": attr.label(
            default = ":BUILD.binary.bzl",
        ),
    }
)
