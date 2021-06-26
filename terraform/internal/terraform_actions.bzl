load("@io_bazel_rules_docker//skylib:path.bzl", _get_runfile_path = "runfile")

"""
runfiles is a helper function to get the correct environment for shell template
runnable targets. Copied from rules_k8s.
"""

def runfiles(ctx, f):
    return "${RUNFILES}/%s" % _get_runfile_path(ctx, f)

def _terraform_command(ctx, cmd, args = ""):
    toolchain = ctx.toolchains["@rules_terraform//terraform:toolchain_type"]
    module_dir = ctx.files.srcs[0].dirname
    ctx.actions.expand_template(
        template = ctx.file._template,
        substitutions = {
            "%{tf_binary}": runfiles(ctx, toolchain.binary),
            "%{module_dir}": module_dir,
            "%{command}": cmd,
            "%{args}": args,
        },
        output = ctx.outputs.executable,
    )
    return [
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = [
                    toolchain.binary,
                    ctx.file._template,
                ] + ctx.files.srcs,
            ),
        ),
    ]


def _terraform_apply_impl(ctx):
    return _terraform_command(ctx, "apply", "-auto-approve")

terraform_apply = rule(
    implementation = _terraform_apply_impl,
    attrs = {
        "_template": attr.label(
            default = ":tf_exec.sh.tpl",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    executable = True,
    toolchains = ["@rules_terraform//terraform:toolchain_type"],
)

def _terraform_plan_impl(ctx):
    return _terraform_command(ctx, "plan")

terraform_plan = rule(
    implementation = _terraform_plan_impl,
    attrs = {
        "_template": attr.label(
            default = ":tf_exec.sh.tpl",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    executable = True,
    toolchains = ["@rules_terraform//terraform:toolchain_type"],
)
