load(":terraform_actions.bzl", "terraform_apply", "terraform_plan")

def terraform_module(name, srcs = [], modules = [], **kwargs):
    native.filegroup(
        name = name,
        srcs = srcs,
        data = modules,
        **kwargs,
    )

    terraform_apply(
        name = name + ".apply",
        srcs = [name] + modules,
    )
    terraform_plan(
        name = name + ".plan",
        srcs = [name] + modules,
    )
