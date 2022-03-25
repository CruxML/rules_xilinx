load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "vivado_bitstream")

exports_files([
    "some_bd.tcl",
])

verilog_module(
    name = "empty_top",
    srcs = ["empty_top.sv"],
    top = "empty_top",
)

vivado_bitstream(
    name = "empty",
    board_designs = [":some_bd.tcl"],
    constraints = ["//tests:constraints.xdc"],
    module = ":empty_top",
    part_number = "xczu28dr-ffvg1517-2-e",
    xilinx_env = "//tests:xilinx_env.sh",
)
