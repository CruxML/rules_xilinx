"""Definitions for rules_xilinx"""

load("@rules_verilog//verilog:defs.bzl", "VerilogModuleInfo")

VivadoInfo = provider(
    doc = "Information about a Vivado target",
    fields = ["part"],
)

def _vivado_bitstream_impl(ctx):
    synth_dcp = ctx.actions.declare_file("{}_synth.dcp".format(ctx.label.name))
    route_dcp = ctx.actions.declare_file("{}_route.dcp".format(ctx.label.name))
    bitstream = ctx.actions.declare_file("{}.bit".format(ctx.label.name))
    vivado_log = ctx.actions.declare_file("{}.log".format(ctx.label.name))
    run_tcl = ctx.actions.declare_file("run.tcl")

    args = []
    if ctx.attr.module[VerilogModuleInfo].files:
        args.append("--sv_files")

    # TODO(stridge-cruxml) Look at the extension to determine where to add.
    for file in ctx.attr.module[VerilogModuleInfo].files.to_list():
        args.append(file.path)

    if ctx.attr.board_designs:
        args.append("--tcl_files")
    for target in ctx.attr.board_designs:
        args.append(target.files.to_list()[0].path)

    if ctx.attr.constraints:
        args.append("--xdc_files")
    for target in ctx.attr.constraints:
        args.append(target.files.to_list()[0].path)

    args.append("-t")
    args.append(ctx.attr.module[VerilogModuleInfo].top)
    args.append("--part_number")
    args.append(ctx.attr.part_number)
    args.append("--synth_dcp")
    args.append(synth_dcp.path)
    args.append("--route_dcp")
    args.append(route_dcp.path)
    args.append("--bitstream")
    args.append(bitstream.path)
    args.append("--output_file")
    args.append(run_tcl.path)

    ctx.actions.run(
        outputs = [run_tcl],
        inputs = [],
        arguments = args,
        progress_message = "Generating run.tcl",
        mnemonic = "GenRunSynthTcl",
        executable = ctx.executable.template_gen,
    )

    xilinx_env_files = ctx.attr.xilinx_env.files.to_list()
    xilinx_env = xilinx_env_files[0]

    # Vivado needs HOME variable defined for the tcl store.
    command = "source " + xilinx_env.path + " && "
    command += "vivado -mode batch -source " + run_tcl.path + " -log " + vivado_log.path

    ctx.actions.run_shell(
        outputs = [synth_dcp, route_dcp, bitstream, vivado_log],
        inputs = ctx.attr.module[VerilogModuleInfo].files.to_list() + ctx.files.board_designs + ctx.files.constraints + [run_tcl, xilinx_env],
        command = command,
        mnemonic = "VivadoRun",
        use_default_shell_env = True,
        progress_message = "Building {}.bit".format(ctx.attr.module[VerilogModuleInfo].top),
    )

    return [
        DefaultInfo(files = depset([synth_dcp, route_dcp, bitstream, vivado_log])),
        VivadoInfo(part = ctx.attr.part_number),
    ]

vivado_bitstream = rule(
    implementation = _vivado_bitstream_impl,
    doc = "Run vivado bitstream.",
    attrs = {
        "module": attr.label(
            doc = "Top level module.",
            mandatory = True,
            providers = [VerilogModuleInfo],
        ),
        "part_number": attr.string(
            doc = "Xilinx part number.",
            mandatory = True,
        ),
        "board_designs": attr.label_list(
            doc = "The exported tcl for a Vivado board design.",
            allow_files = [".tcl"],
        ),
        "constraints": attr.label_list(
            doc = "Constraints for synthesis and later stages.",
            allow_files = [".xdc"],
        ),
        "xilinx_env": attr.label(
            doc = "Environment variables for xilinx tools.",
            allow_files = [".sh"],
            mandatory = True,
        ),
        "template_gen": attr.label(
            doc = "Tool used to generate run.tcl. A custom tool can be used.",
            executable = True,
            cfg = "exec",
            default = "@com_cruxml_rules_xilinx//xilinx/tools:gen_template",
        ),
    },
)
