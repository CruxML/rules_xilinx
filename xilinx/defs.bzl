"""Definitions for rules_xilinx"""

load("@rules_verilog//verilog:defs.bzl", "VerilogModuleInfo")

VivadoSynthInfo = provider(
    doc = "Information about a Vivado synthesis target",
    fields = ["synth_constraints", "part"],
)

def _vivado_synth_impl(ctx):
    synth_dcp = ctx.actions.declare_file("{}_synth.dcp".format(ctx.label.name))
    run_synth_tcl = ctx.actions.declare_file("run_synth.tcl")

    args = []
    if ctx.attr.module[VerilogModuleInfo].files:
        args.append("--sv_files")
    for file in ctx.attr.module[VerilogModuleInfo].files.to_list():
        args.append(file.path)
    args.append("-t")
    args.append(ctx.attr.module[VerilogModuleInfo].top)
    args.append("--part_number")
    args.append(ctx.attr.part_number)
    args.append("--output_dcp")
    args.append(synth_dcp.path)
    args.append("--output_file")
    args.append(run_synth_tcl.path)

    ctx.actions.run(
        outputs = [run_synth_tcl],
        inputs = [],
        arguments = args,
        progress_message = "Generating run_synth.tcl",
        mnemonic = "GenRunSynthTcl",
        executable = ctx.executable.template_gen,
    )

    # Vivado needs HOME variable defined for the tcl store.
    command = "export HOME=/tmp; vivado -mode batch -source " + run_synth_tcl.path

    ctx.actions.run_shell(
        outputs = [synth_dcp],
        inputs = ctx.attr.module[VerilogModuleInfo].files.to_list() + ctx.files.board_designs + [run_synth_tcl],
        command = command,
        mnemonic = "VivadoSynth",
        use_default_shell_env = True,
        progress_message = "Synthesizing {}".format(ctx.attr.module[VerilogModuleInfo].top),
    )

    return [
        DefaultInfo(files = depset([synth_dcp])),
        VivadoSynthInfo(part = ctx.attr.part_number),
    ]

vivado_synth = rule(
    implementation = _vivado_synth_impl,
    doc = "Run vivado synthesis.",
    attrs = {
        "module": attr.label(
            doc = "Module for bitstream.",
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
        "template_gen": attr.label(
            doc = "Tool used to generate run_synth.tcl",
            executable = True,
            cfg = "exec",
            default = "@com_cruxml_rules_xilinx//xilinx/tools:synth_template",
        ),
    },
)
