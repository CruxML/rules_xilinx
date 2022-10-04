load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@com_cruxml_rules_xilinx//xilinx:defs.bzl", "xsim_test")

# ------------------- Test fifo pass -------------------
def _fifo_xsim_pass_test_impl(ctx):
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)

    # Test log should be generated
    test_log_finder = False
    for action in actions:
        if action.mnemonic == "TestRunner":
            test_log_finder = True
    asserts.true(env, test_log_finder)

    return analysistest.end(env)

fifo_xsim_pass_test = analysistest.make(
    _fifo_xsim_pass_test_impl,
)

def _test_xsim_pass_contents():
    xsim_test(
        name = "fifo_xsim_pass",
        module = ":fifo_tb",
        part_number = "xczu49dr-ffvf1760-2-e",
        verilog_flags = "--define PASSING_TEST",
        xilinx_env = "//tests:xilinx_env.sh",
        tags = ["manual"],
    )

    fifo_xsim_pass_test(
        name = "fifo_xsim_pass_test",
        target_under_test = ":fifo_xsim_pass",
    )

def xsim_pass_test_suite(name):
    _test_xsim_pass_contents()
    native.test_suite(
        name = name,
        tests = [
            ":fifo_xsim_pass_test",
        ],
    )

# ------------------- Test fifo fail -------------------
def _fifo_xsim_fail_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Without the passing flag, this rule should fail.")

    actions = analysistest.target_actions(env)

    # Test log should be generated
    test_log_finder = False
    for action in actions:
        if action.mnemonic == "TestRunner":
            test_log_finder = True
    asserts.true(env, test_log_finder)

    return analysistest.end(env)

fifo_xsim_fail_test = analysistest.make(
    _fifo_xsim_fail_test_impl,
    expect_failure = True,
)

def _test_xsim_fail_contents():
    xsim_test(
        name = "fifo_xsim_fail",
        module = ":fifo_tb",
        part_number = "xczu49dr-ffvf1760-2-e",
        verilog_flags = "",
        xilinx_env = "//tests:xilinx_env.sh",
        tags = ["manual"],
    )

    fifo_xsim_pass_test(
        name = "fifo_xsim_fail_test",
        target_under_test = ":fifo_xsim_fail",
    )

def xsim_fail_test_suite(name):
    _test_xsim_fail_contents()

    native.test_suite(
        name = name,
        tests = [
            ":fifo_xsim_fail_test",
        ],
    )
