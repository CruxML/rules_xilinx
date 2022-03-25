load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "vivado_bitstream")

exports_files([
    "constraints.xdc",
    "zynq_axi.tcl",
])

verilog_module(
    name = "zcu111_submodule",
    srcs = ["zcu111_submodule.sv"],
    top = "zcu111_submodule",
)

verilog_module(
    name = "zcu111_top",
    srcs = ["zcu111_top.sv"],
    top = "zcu111_top",
    deps = [
        ":zcu111_submodule",
    ],
)

vivado_bitstream(
    name = "zcu111",
    board_designs = [":zynq_axi.tcl"],
    constraints = ["//tests:constraints.xdc"],
    module = ":zcu111_top",
    part_number = "xczu28dr-ffvg1517-2-e",
    xilinx_env = "//tests:xilinx_env.sh",
)
