"""Setup with deps 1"""

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_python//python:pip.bzl", "pip_parse")
load(
    "@rules_verilator//verilator:repositories.bzl",
    "rules_verilator_dependencies",
    "rules_verilator_toolchains",
)

def rules_xilinx_deps_2():
    bazel_skylib_workspace()

    pip_parse(
        name = "pip",
        requirements_lock = "//:requirements.txt",
    )

    rules_verilator_dependencies()

    rules_verilator_toolchains()
