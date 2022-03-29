"""Setup with deps 2"""

load("@pip//:requirements.bzl", "install_deps")
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")
load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")

def rules_xilinx_deps_3():
    install_deps()
    m4_register_toolchains()

    flex_register_toolchains()

    bison_register_toolchains()
