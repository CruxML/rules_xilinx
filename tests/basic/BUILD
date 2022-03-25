load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "vivado_synth")

verilog_module(
    name = "empty_top",
    srcs = ["empty_top.sv"],
    top = "empty_top",
)

vivado_synth(
    name = "empty",
    module = ":empty_top",
    part_number = "xc7a35ticsg324-1l",
    vivado_path = "/opt/xilinx/Vivado/2021.2/bin/vivado",
)
