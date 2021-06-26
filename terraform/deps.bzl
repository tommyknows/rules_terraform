load("//terraform/internal:tf_download.bzl", "terraform_download")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def terraform_dependencies():
    terraform_download(
        name = "terraform_macos_amd64",
        urls = ["https://releases.hashicorp.com/terraform/1.0.1/terraform_1.0.1_darwin_amd64.zip"],
        sha256 = "32c5b3123bc7a4284131dbcabd829c6e72f7cc4df7a83d6e725eb97905099317",
        os = "darwin",
        arch = "amd64",
    )

    terraform_download(
        name = "terraform_linux_amd64",
        urls = ["https://releases.hashicorp.com/terraform/1.0.1/terraform_1.0.1_linux_amd64.zip"],
        sha256 = "da94657593636c8d35a96e4041136435ff58bb0061245b7d0f82db4a7728cef3",
        os = "linux",
        arch = "amd64",
    )

    native.register_toolchains(
        "@terraform_macos_amd64//:toolchain",
        "@terraform_linux_amd64//:toolchain",
    )

    _maybe(
        repo_rule = git_repository,
        name = "io_bazel_rules_docker",
        commit = "7da0de3d094aae5601c45ae0855b64fb2771cd72",
        remote = "https://github.com/bazelbuild/rules_docker",
        shallow_since = "1608668127 -0500",
    )

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
