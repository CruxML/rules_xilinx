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
        "-p",
        "--project_name",
        action="store",
        default="my_hls_project",
        help="Vitis Project name to create",
    )
    parser.add_argument(
        "--part_number",
        action="store",
        default="xczu28dr-ffvg1517-2-e",
        help="The target fpga part number for this hls generated verilog.",
    )
    parser.add_argument(
        "-t",
        "--top_level_function",
        action="store",
        required=True,
        help="The top level function to create a module around.",
    )
    parser.add_argument(
        "-c",
        "--clock_period",
        action="store",
        type=float,
        required=True,
        help="The target clock period to compile this block for in ns.",
    )
    parser.add_argument(
        "-o",
        "--output_file",
        action="store",
        required=True,
        help="The output filename to store the rendered template.",
    )
    parser.add_argument("files", nargs="+", help="Files required by vitis.")

    options = parser.parse_args()

    template_file = os.path.join(os.path.dirname(__file__), "run_hls.tcl.jinja")
    template_params = {
        "project_name": options.project_name,
        "files": options.files,
        "top_level_function": options.top_level_function,
        "part_number": options.part_number,
        "clock_period": options.clock_period,
    }
    generate_from_template(options.output_file, template_file, template_params)
