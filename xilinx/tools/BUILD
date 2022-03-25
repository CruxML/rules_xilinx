load("@pip//:requirements.bzl", "requirement")

exports_files(["run.tcl.jinja"])

py_binary(
    name = "gen_template",
    srcs = ["gen_template.py"],
    data = [":run.tcl.jinja"],
    visibility = ["//visibility:public"],
    deps = [
        requirement("jinja2"),
    ],
)
