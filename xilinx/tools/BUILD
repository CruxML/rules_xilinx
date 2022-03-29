load("@pip//:requirements.bzl", "requirement")

exports_files([
    "run.tcl.jinja",
    "run_hls.tcl.jinja",
])

py_binary(
    name = "gen_template",
    srcs = ["gen_template.py"],
    data = [":run.tcl.jinja"],
    visibility = ["//visibility:public"],
    deps = [
        requirement("jinja2"),
    ],
)

py_binary(
    name = "gen_hls_template",
    srcs = ["gen_hls_template.py"],
    data = [":run_hls.tcl.jinja"],
    visibility = ["//visibility:public"],
    deps = [
        requirement("jinja2"),
    ],
)
