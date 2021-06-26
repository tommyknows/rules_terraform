load("//terraform/internal:tf_download.bzl", "terraform_download", "terraform_download_sumfile")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

AVAILABLE_RELEASES = {
    "darwin": ["amd64"],
    "linux": ["amd64", "arm64"],
    "windows": ["amd64"],
}

VERSIONS = {
    "1.0.1": "183842fb11dc6a84c63ef629f09bf364d78a943722af1d54d82aac3e5100b7cb",
}

def terraform_dependencies(version = "1.0.1", sha256 = ""):
    if version in VERSIONS:
        sha256 = VERSIONS[version]
    elif sha256 == "":
        fail("version not in index and no sha256 sum given!")

    terraform_download_sumfile(
        name = "sumfile",
        version = version,
        sha256 = sha256,
    )

    for os, archs in AVAILABLE_RELEASES.items():
        for arch in archs:
            terraform_download(
                name = "terraform_{os}_{arch}".format(os = os, arch = arch),
                version = version,
                os = os,
                arch = arch,
                sumfile = "@sumfile",
            )
            native.register_toolchains(
                "@terraform_{os}_{arch}//:toolchain".format(os = os, arch = arch),
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
