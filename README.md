# rules_xilinx

Bazel rules to interface to xilinx tools such as vivado, vitis_hls and xsim (currently not implemented).

## Getting Started

To your `WORKSPACE` file add:
```
git_repository(
    name = "com_cruxml_rules_xilinx",
    commit = "245e1d67ebbcdf86a9a8c524f6d75d4f3c7342c9",
    remote = "https://github.com/CruxML/rules_xilinx.git",
)

load("@com_cruxml_rules_xilinx//xilinx:rules_xilinx_deps_1.bzl", "rules_xilinx_deps_1")

rules_xilinx_deps_1()

load("@com_cruxml_rules_xilinx//xilinx:rules_xilinx_deps_2.bzl", "rules_xilinx_deps_2")

rules_xilinx_deps_2()

load("@com_cruxml_rules_xilinx//xilinx:rules_xilinx_deps_3.bzl", "rules_xilinx_deps_3")

rules_xilinx_deps_3()
```

Create a Vivado bitstream with:
```
load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "vivado_bitstream")

verilog_module(
    name = "some_module",
    srcs = ["some_module.sv"],
    top = "some_module",
    deps = [":other", ":modules"],
)

vivado_bitstream(
    name = "gen_some_module",
    board_designs = [":some_bd.tcl"],
    constraints = ["//path/to:constraints.xdc"],
    module = ":some_module",
    part_number = "xczu28dr-ffvg1517-2-e",
    xilinx_env = "//path/to:xilinx_env.sh",
)
```

Note the `xilinx_env` key word provides a script to source settings and set the license variables you wish to use.

See the `tests` directory for more examples, including HLS examples.

## Design for Vivado

### Differences with rules_vivado

This was developed with reference to the great [rules_vivado](https://github.com/agoessling/rules_vivado) project.
However, I have found some limitiations with the server client approach in that project.
In particular, it effectively prohibits multiple users using the same machine to build.
The report parsing was baked in too which made custom filtering an issue.
Additionally, it would be nice to package other xilinx tools such as vitis_hls and xsim into the same package.

### rules_xilinx approach

Jinja2 is used to template a tcl file. Then variables such as the filenames, part to target will be applied to the template.
Vivado directly source this generated tcl file to build a bitstream.

It is intended to implement customizable report parsers evaluate vivado output to pass or fail the result.

## Design for Vitis

Vitis has a bunch of files to include that define HLS primitives. These files are added directly into this repo.
They can be dependency targets for tests. Define in the vitis script the variable VITIS to allow ifdef includes.

## Design for xsim

TODO(stridge-cruxml)

## Known Issues

`rules_verilator` does not seem to be compatible with bazel `5.0.0`. Use bazel `4.2.1`.
