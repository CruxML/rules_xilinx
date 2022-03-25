"""Setup with deps 1"""

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_python//python:pip.bzl", "pip_parse")

def rules_xilinx_deps_2():
    bazel_skylib_workspace()

    pip_parse(
        name = "pip",
        requirements_lock = "//:requirements.txt",
    )
