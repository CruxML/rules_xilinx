"""Definitions for rules_xilinx"""

load("@rules_verilog//verilog:defs.bzl", "VerilogModuleInfo")

VivadoInfo = provider(
    doc = "Information about a Vivado target",
    fields = ["part"],
)

HlsFileInfo = provider(
    "HLS files required by vitis",
    fields = {
        "count": "number of files",
        "files": "a list of files",
    },
)

def _vitis_hls_files_aspect_impl(target, ctx):
    count = 0
    files = []

    # Make sure the rule has a srcs attribute.
    if hasattr(ctx.rule.attr, "srcs"):
        # Iterate through the sources counting files
        for src in ctx.rule.attr.srcs:
            for f in src.files.to_list():
                if "vitis/" not in f.dirname:
                    count = count + 1
                    files.append(f)
    if hasattr(ctx.rule.attr, "hdrs"):
        # Iterate through the sources counting files
        for src in ctx.rule.attr.hdrs:
            for f in src.files.to_list():
                if "vitis/" not in f.dirname:
                    count = count + 1
                    files.append(f)

    # Get the counts from our dependencies.
    for dep in ctx.rule.attr.deps:
        count = count + dep[HlsFileInfo].count
        files = files + dep[HlsFileInfo].files
    return [HlsFileInfo(count = count, files = files)]

vitis_hls_files_aspect = aspect(
    implementation = _vitis_hls_files_aspect_impl,
    attr_aspects = ["deps"],
)

def _vitis_generate_impl(ctx):
    output_file = ctx.actions.declare_file("run_hls.tcl")

    all_files = []
    for dep in ctx.attr.deps:
        for file in dep[HlsFileInfo].files:
            all_files.append(file)

    args = []
    for file in all_files:
        args.append(file.path)
    args.append("-t")
    args.append(ctx.attr.top_func)
    args.append("-c")
    args.append(ctx.attr.clock_period)
    args.append("--part_number")
    args.append(ctx.attr.part_number)
    args.append("-o")
    args.append(output_file.path)

    ctx.actions.run(
        outputs = [output_file],
        inputs = [],
        arguments = args,
        progress_message = "Generating run_hls.tcl",
        executable = ctx.executable.template_gen,
    )

    xilinx_env_files = ctx.attr.xilinx_env.files.to_list()
    xilinx_env = xilinx_env_files[0]

    # Vivado needs HOME variable defined for the tcl store.
    vitis_command = "source " + xilinx_env.path + " && "
    vitis_command += "vitis_hls " + output_file.path
    out_file = ctx.outputs.out
    vitis_command += " && tar -czvf " + out_file.path + " -C my_hls_project/sol1/impl/verilog ."
    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs = all_files + [output_file, xilinx_env],
        progress_message = "Running vitis",
        command = vitis_command,
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.out, output_file])),
    ]

vitis_generate = rule(
    implementation = _vitis_generate_impl,
    attrs = {
        "top_func": attr.string(doc = "The name of the top level function.", mandatory = True),
        "clock_period": attr.string(doc = "The clock period for the module.", mandatory = True),
        "part_number": attr.string(doc = "The part number to use. Default is ZCU111", default = "xczu28dr-ffvg1517-2-e"),
        "deps": attr.label_list(doc = "The file to generate from", aspects = [vitis_hls_files_aspect], mandatory = True),
        "out": attr.output(doc = "The generated verilog files", mandatory = True),
        "template_gen": attr.label(
            doc = "The tool to use to generate run_hls.tcl.",
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@com_cruxml_rules_xilinx//xilinx/tools:gen_hls_template"),
        ),
        "xilinx_env": attr.label(
            doc = "Environment variables for xilinx tools.",
            allow_files = [".sh"],
            mandatory = True,
        ),
    },
)

def _vivado_hls_files_aspect_impl(target, ctx):
    count = 0
    files = []

    # Make sure the rule has a srcs attribute.
    if hasattr(ctx.rule.attr, "srcs"):
        # Iterate through the sources counting files
        for src in ctx.rule.attr.srcs:
            for f in src.files.to_list():
                if "vivado/" not in f.dirname:
                    count = count + 1
                    files.append(f)
    if hasattr(ctx.rule.attr, "hdrs"):
        # Iterate through the sources counting files
        for src in ctx.rule.attr.hdrs:
            for f in src.files.to_list():
                if "vivado/" not in f.dirname:
                    count = count + 1
                    files.append(f)

    # Get the counts from our dependencies.
    for dep in ctx.rule.attr.deps:
        count = count + dep[HlsFileInfo].count
        files = files + dep[HlsFileInfo].files
    return [HlsFileInfo(count = count, files = files)]

vivado_hls_files_aspect = aspect(
    implementation = _vivado_hls_files_aspect_impl,
    attr_aspects = ["deps"],
)

def _vivado_generate_impl(ctx):
    output_file = ctx.actions.declare_file("run_hls.tcl")

    all_files = []
    for dep in ctx.attr.deps:
        for file in dep[HlsFileInfo].files:
            all_files.append(file)

    args = []
    for file in all_files:
        args.append(file.path)
    args.append("-t")
    args.append(ctx.attr.top_func)
    args.append("-c")
    args.append(ctx.attr.clock_period)
    args.append("--cf")
    args.append(ctx.attr.cflags)
    args.append("--part_number")
    args.append(ctx.attr.part_number)
    args.append("-o")
    args.append(output_file.path)

    ctx.actions.run(
        outputs = [output_file],
        inputs = [],
        arguments = args,
        progress_message = "Generating run_hls.tcl",
        executable = ctx.executable.template_gen,
    )

    xilinx_env_files = ctx.attr.xilinx_env.files.to_list()
    xilinx_env = xilinx_env_files[0]

    # Vivado needs HOME variable defined for the tcl store.
    vivado_command = "source " + xilinx_env.path + " && "
    vivado_command += "vivado_hls " + output_file.path
    out_file = ctx.outputs.out
    vivado_command += " && tar -czvf " + out_file.path + " -C my_hls_project/sol1/impl/verilog ."
    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs = all_files + [output_file, xilinx_env],
        progress_message = "Running vivado_hls",
        command = vivado_command,
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.out, output_file])),
    ]

vivado_generate = rule(
    implementation = _vivado_generate_impl,
    attrs = {
        "top_func": attr.string(doc = "The name of the top level function.", mandatory = True),
        "clock_period": attr.string(doc = "The clock period for the module.", mandatory = True),
        "cflags": attr.string(doc = "The compiler flags.", default = "-DVITIS=1 "),
        "part_number": attr.string(doc = "The part number to use. Default is ZCU111", default = "xczu28dr-ffvg1517-2-e"),
        "deps": attr.label_list(doc = "The file to generate from", aspects = [vivado_hls_files_aspect], mandatory = True),
        "out": attr.output(doc = "The generated verilog files", mandatory = True),
        "template_gen": attr.label(
            doc = "The tool to use to generate run_hls.tcl.",
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@com_cruxml_rules_xilinx//xilinx/tools:gen_hls_template"),
        ),
        "xilinx_env": attr.label(
            doc = "Environment variables for xilinx tools.",
            allow_files = [".sh"],
            mandatory = True,
        ),
    },
)

def _vivado_bitstream_impl(ctx):
    synth_dcp = ctx.actions.declare_file("{}_synth.dcp".format(ctx.label.name))
    route_dcp = ctx.actions.declare_file("{}_route.dcp".format(ctx.label.name))
    bitstream = ctx.actions.declare_file("{}.bit".format(ctx.label.name))
    vivado_log = ctx.actions.declare_file("{}.log".format(ctx.label.name))
    run_tcl = ctx.actions.declare_file("run.tcl")

    synth_timing_report = ctx.actions.declare_file("post_synth_timing_summary.rpt")
    synth_util_report = ctx.actions.declare_file("post_synth_util.rpt")
    route_status_report = ctx.actions.declare_file("post_route_status.rpt")
    route_timing_report = ctx.actions.declare_file("post_route_timing_summary.rpt")
    route_power_report = ctx.actions.declare_file("post_route_power.rpt")
    route_drc_report = ctx.actions.declare_file("post_imp_drc.rpt")
    reports = [synth_timing_report, synth_util_report, route_status_report, route_timing_report, route_power_report, route_drc_report]

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
        outputs = [synth_dcp, route_dcp, bitstream, vivado_log] + reports,
        inputs = ctx.attr.module[VerilogModuleInfo].files.to_list() + ctx.attr.module[VerilogModuleInfo].data_files.to_list() + ctx.files.board_designs + ctx.files.constraints + [run_tcl, xilinx_env],
        command = command,
        mnemonic = "VivadoRun",
        use_default_shell_env = True,
        progress_message = "Building {}.bit".format(ctx.attr.module[VerilogModuleInfo].top),
    )

    # TODO(stridge-cruxml) Call a python script to analyze vivado_log.path and error check.

    return [
        DefaultInfo(files = depset([synth_dcp, route_dcp, bitstream, vivado_log] + reports)),
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
