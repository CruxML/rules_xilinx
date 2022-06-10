""" Direct repos to include."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def rules_xilinx_deps_1():
    http_archive(
        name = "bazel_skylib",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    )

    http_archive(
        name = "rules_python",
        sha256 = "cd6730ed53a002c56ce4e2f396ba3b3be262fd7cb68339f0377a45e8227fe332",
        urls = [
            "https://github.com/bazelbuild/rules_python/releases/download/0.5.0/rules_python-0.5.0.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/rules_python/releases/download/0.5.0/rules_python-0.5.0.tar.gz",
        ],
    )

    http_archive(
        name = "com_github_gflags_gflags",
        sha256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf",
        strip_prefix = "gflags-2.2.2",
        urls = ["https://github.com/gflags/gflags/archive/v2.2.2.tar.gz"],
    )

    http_archive(
        name = "com_github_google_glog",
        sha256 = "21bc744fb7f2fa701ee8db339ded7dce4f975d0d55837a97be7d46e8382dea5a",
        strip_prefix = "glog-0.5.0",
        urls = ["https://github.com/google/glog/archive/v0.5.0.zip"],
    )

    git_repository(
        name = "gtest",
        commit = "6a7ed316a5cdc07b6d26362c90770787513822d4",
        remote = "https://github.com/google/googletest",
    )

    git_repository(
        name = "rules_verilator",
        commit = "b909e3e0c9e1e6b89b1ac4f304e4258b3dd1b6f2",
        remote = "https://github.com/CruxML/rules_verilator.git",
    )
