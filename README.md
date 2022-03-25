# rules_xilinx

Bazel rules to interface to xilinx tools such as vivado, vitis_hls and xsim.

## Background

This was developed with reference to the great [rules_vivado](https://github.com/agoessling/rules_vivado) project.
However, I have found some limitiations with the server client approach in that project.
In particular, it effectively prohibits multiple users using the same machine to build.
The report parsing was baked in too which made custom filtering an issue.
Additionally, it would be nice to package other xilinx tools such as vitis_hls and xsim into the same package.

## Design for Vivado

Jinja2 is used to template a tcl file. Then variables such as the filenames, part to target will be applied to the template.
Vivado directly source this generated tcl file to build a bitstream.

Customizable report parsers evaluate vivado output to pass or fail the result.

## Design for Vitis

Vitis has a bunch of files to include that define HLS primitives. These files are added directly into this repo.
They can be dependency targets for tests. Define in the vitis script the variable VITIS to allow ifdef includes.

## Design for xsim

TODO(stridge-cruxml)
