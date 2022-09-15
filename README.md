# rules_xilinx

Bazel rules to interface to xilinx tools such as vivado, vitis_hls and xsim (currently not implemented).

## Getting Started

To your `WORKSPACE` file add:
```bzl
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
```bzl
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

Note the `xilinx_env` argument provides a script to source settings and set the vivado license variables you wish to use.

For hls:

```bzl
# Define the hls lib. This will grab the includes from this repo.
cc_library(
    name = "hls_adder",
    srcs = ["hls_adder.cc"],
    hdrs = ["hls_adder.h"],
    deps = ["@com_cruxml_rules_xilinx//vitis:v2021_2_cc"],
)

# Define a C++ test on the HLS.
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

# Make a target to generate the verilog with vitis.
# Note the xilinx_env.sh file sources the settings64.sh in Vitis.
# It generates adder.tar.gz, the generated verilog.
vitis_generate(
    name = "gen_adder",
    out = "adder.tar.gz",
    clock_period = "10.0",
    top_func = "adder",
    xilinx_env = "//tests:xilinx_env.sh",
    deps = [":hls_adder"],
)

# Extract adder.tar.gz to adder/ and create a rule like this.
# This allows systems without access to vitis to still use the generated code.
# Alternatively you could make a rule to extract the tar.gz too, to avoid checking in
# generated code.
verilog_module(
    name = "adder",
    srcs = glob(["adder/*"]),
    top = "adder",
)

# Compile a verilator module using the generated verilog.
verilator_cc_library(
    name = "adder_verilator",
    module = ":adder",
    # Disable all warnings for HLS generated verilog.
    vopts = [],
)

# Add a test on the verilated module. Also depends on the
# original module to compare the SW and HW versions.
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
```


See the `tests` directory for more working examples.

### Opening the project in the GUI

It is necessary to use the Vivado GUI at times.
The easiest way is to just use the checkpoints that are written in bitstream creation.
Alternatively, run the bitstream build with `--sandbox_debug`. This will keep the vivado project state when building.
This will print a path of the working directory. In this directory, there is `myproj/project_1.xpr` which can be opened with the GUI.


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
They can be dependency targets for cpp tests. By adding a dependency on `@com_cruxml_rules_xilinx//vitis:v2021_2_cc` you can
include deps as follows:

```cpp
#ifdef VITIS
#include <ap_fixed.h>
#else
#include "vitis/v2021_2/ap_fixed.h"
#endif
```

`VITIS` is defined during verilog generation with vitis where the includes are built in.

## Design for xsim

TODO(stridge-cruxml) Add rules to run xsim.

## Known Issues

`rules_verilator` does not seem to be compatible with bazel `5.0.0`. Use bazel `4.2.1`.
