load("@pip//:requirements.bzl", "requirement")

exports_files(["run_synth.tcl.jinja"])

py_binary(
    name = "synth_template",
    srcs = ["synth_template.py"],
    data = [":run_synth.tcl.jinja"],
    visibility = ["//visibility:public"],
    deps = [
        requirement("jinja2"),
    ],
)
