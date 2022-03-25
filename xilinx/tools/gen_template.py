import jinja2
import os
import argparse


def generate_from_template(output_file, template_file, template_params={}):
    """Apply template parameters to a template file and generate output_file.
    Args:
        output_file: Filename to save the rendered template.
        template_file: The template file to load.
        template_params: A dictionary of "variable" : "value".
    """
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(os.path.dirname(template_file)),
        autoescape=jinja2.select_autoescape(),
    )
    template = env.get_template(os.path.basename(template_file))
    output_data = template.render(template_params)
    with open(output_file, "w") as f:
        f.write(output_data)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--part_number",
        action="store",
        required=True,
        help="The target fpga part number.",
    )
    parser.add_argument(
        "-t",
        "--top_module",
        action="store",
        required=True,
        help="The top level module to synthesize.",
    )
    parser.add_argument(
        "--synth_dcp",
        action="store",
        required=True,
        help="The output dcp filename for synthesis.",
    )
    parser.add_argument(
        "--route_dcp",
        action="store",
        required=True,
        help="The output dcp filename for routing.",
    )
    parser.add_argument(
        "--bitstream",
        action="store",
        required=True,
        help="The bitstream output.",
    )
    parser.add_argument(
        "-o",
        "--output_file",
        action="store",
        required=True,
        help="The output filename for the generated template.",
    )

    parser.add_argument("--sv_files", nargs="+", help="System verilog input files.")
    parser.add_argument("--tcl_files", nargs="+", help="Tcl input files.")
    parser.add_argument("--xdc_files", nargs="+", help="Xdc input files.")

    options = parser.parse_args()

    template_file = os.path.join(os.path.dirname(__file__), "run.tcl.jinja")
    template_params = {
        "sv_files": options.sv_files if options.sv_files else [],
        "xdc_files": options.xdc_files if options.xdc_files else [],
        "tcl_files": options.tcl_files if options.tcl_files else [],
        "top_module": options.top_module,
        "part_number": options.part_number,
        "synth_dcp": options.synth_dcp,
        "route_dcp": options.route_dcp,
        "bitstream": options.bitstream,
        "jobs": 4,
    }
    generate_from_template(options.output_file, template_file, template_params)
