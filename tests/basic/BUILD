load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "vitis_generate", "vivado_bitstream", "vivado_generate")
load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")

exports_files([
    "some_bd.tcl",
])

verilog_module(
    name = "empty_top",
    srcs = ["empty_top.sv"],
    top = "empty_top",
    deps = [":adder"],
)

vivado_bitstream(
    name = "empty",
    board_designs = [":some_bd.tcl"],
    constraints = ["//tests:constraints.xdc"],
    module = ":empty_top",
    part_number = "xczu28dr-ffvg1517-2-e",
    xilinx_env = "//tests:xilinx_env.sh",
)

cc_library(
    name = "hls_adder",
    srcs = ["hls_adder.cc"],
    hdrs = ["hls_adder.h"],
    deps = ["//vitis:v2021_2_cc"],
)

cc_library(
    name = "hls_adder_vivado",
    srcs = ["hls_adder_vivado.cc"],
    hdrs = ["hls_adder_vivado.h"],
    deps = ["//vivado:v2020_1_cc"],
)

cc_test(
    name = "hls_adder_test",
    srcs = ["hls_adder_test.cc"],
    deps = [
        ":hls_adder",
        "@com_github_google_glog//:glog",
        "@gtest",
        "@gtest//:gtest_main",
    ],
)

cc_test(
    name = "hls_adder_vivado_test",
    srcs = ["hls_adder_vivado_test.cc"],
    deps = [
        ":hls_adder_vivado",
        "@com_github_google_glog//:glog",
        "@gtest",
        "@gtest//:gtest_main",
    ],
)

vitis_generate(
    name = "gen_adder",
    out = "adder.tar.gz",
    clock_period = "10.0",
    top_func = "adder",
    xilinx_env = "//tests:xilinx_env.sh",
    deps = [":hls_adder"],
)

vivado_generate(
    name = "gen_adder_vivado",
    out = "adder_vivado.tar.gz",
    cflags = "-DVITIS=1 ",
    clock_period = "10.0",
    top_func = "adder_vivado",
    xilinx_env = "//tests:vivado_env.sh",
    deps = [":hls_adder_vivado"],
)

# Extract adder.tar.gz to adder/ and create a rule like this.
# This allows systems without access to vitis to still use the generated code.
verilog_module(
    name = "adder",
    srcs = glob(["adder/*"]),
    top = "adder",
)

verilator_cc_library(
    name = "adder_verilator",
    module = ":adder",
    # Disable all warnings for HLS generated verilog.
    vopts = [],
)

cc_test(
    name = "hls_adder_verilator_test",
    srcs = ["hls_adder_verilator_test.cc"],
    deps = [
        ":adder_verilator",
        ":hls_adder",
        "@com_github_google_glog//:glog",
        "@gtest",
        "@gtest//:gtest_main",
    ],
)

verilog_module(
    name = "adder_vivado",
    srcs = glob(["adder_vivado/*"]),
    top = "adder_vivado",
)

verilator_cc_library(
    name = "adder_vivado_verilator",
    module = ":adder_vivado",
    # Disable all warnings for HLS generated verilog.
    vopts = [],
)

cc_test(
    name = "hls_adder_vivado_verilator_test",
    srcs = ["hls_adder_vivado_verilator_test.cc"],
    deps = [
        ":adder_vivado_verilator",
        ":hls_adder_vivado",
        "@com_github_google_glog//:glog",
        "@gtest",
        "@gtest//:gtest_main",
    ],
)

verilog_module(
    name = "load_data",
    srcs = ["load_data.sv"],
    data = ["some_data.dat"],
    top = "load_data",
)

verilator_cc_library(
    name = "load_data_verilator",
    module = ":load_data",
)

cc_test(
    name = "load_data_test",
    srcs = ["load_data_test.cc"],
    deps = [
        ":load_data_verilator",
        "@com_github_google_glog//:glog",
        "@gtest",
        "@gtest//:gtest_main",
    ],
)
