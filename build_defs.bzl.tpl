"""
Hexagon SDK build definitions
"""

load(
    "//:hexagon_envvars.bzl",
    "HEXAGON_ARCH",
    "HEXAGON_SDK_ROOT",
    "HEXAGON_TOOLS_ROOT",
    "HEXAGON_TOOLS_VERSION",
)

def get_hexagon_linkopts(libraries):
    """
    Provides path of specified libraries.

    Args:
        libraries: A list of strings specifying the libraries to link against.
    Returns:
        A list of linker options with path for prebuilt libraries.
    """
    hexagon_sdk_root = HEXAGON_SDK_ROOT
    hexagon_arch = HEXAGON_ARCH
    hexagon_tools_root = HEXAGON_TOOLS_ROOT
    hexagon_tools_version = HEXAGON_TOOLS_VERSION

    if type(libraries) == "string":
        libraries = [libraries]

    lib_paths = {
        "libcpp": [
            "{}/Tools/target/hexagon/lib/{}/G0/pic/libc++abi.so.1".format(hexagon_tools_root, hexagon_arch),
            "{}/Tools/target/hexagon/lib/{}/G0/pic/libc++.so.1".format(hexagon_tools_root, hexagon_arch),
        ],
        "qhl_hvx": [
            "{}/libs/qhl/prebuilt/hexagon_tool{}_{}/libqhblas.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl/prebuilt/hexagon_tool{}_{}/libqhcomplex.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl/prebuilt/hexagon_tool{}_{}/libqhdsp.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl/prebuilt/hexagon_tool{}_{}/libqhmath.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl_hvx/prebuilt/hexagon_tool{}_{}/libqhblas_hvx.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl_hvx/prebuilt/hexagon_tool{}_{}/libqhdsp_hvx.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
            "{}/libs/qhl_hvx/prebuilt/hexagon_tool{}_{}/libqhmath_hvx.a".format(hexagon_sdk_root, hexagon_tools_version, hexagon_arch),
        ],
        "worker_pool_static": [
            "{}/libs/worker_pool/prebuilt/hexagon_tool{}_{}/libworker_pool.a".format(hexagon_sdk_root, hexagon_tools_version, HEXAGON_ARCH),
        ],
    }

    selected_libs = []
    for lib in libraries:
        if lib in lib_paths:
            selected_libs += lib_paths[lib]

    if len(selected_libs) > 0:
        return ["-Wl,--start-group"] + selected_libs + ["-Wl,--end-group"]
    else:
        return []

QAIC_BIN = "{}/ipc/fastrpc/qaic/bin/qaic".format(HEXAGON_SDK_ROOT)
QAIC_INCS = """\
    -I{}/incs/ \
    -I{}/incs/stddef/ \
""".format(HEXAGON_SDK_ROOT, HEXAGON_SDK_ROOT)

def hexagon_qaic_gen(
        name,
        srcs = [],
        outs = [],
        **kwargs):
    native.genrule(
        name = name,
        srcs = srcs,
        outs = outs,
        cmd = "{} -mdll {} -o $(@D) $(SRCS)".format(QAIC_BIN, QAIC_INCS),
        **kwargs
    )

def hexagon_cc_library(
        name,
        srcs = [],
        hdrs = [],
        deps = [],
        **kwargs):
    native.cc_library(
        name = name,
        srcs = srcs + [
            "//:dsp_capabilities_utils_srcs",
            "//:libcdsprpc",
        ],
        hdrs = hdrs,
        deps = deps + [
            "//:headers",
        ],
        **kwargs
    )

def hexagon_skel_library(
        name,
        srcs = [],
        hdrs = [],
        linkopts = [],
        deps = [],
        **kwargs):
    native.cc_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        linkopts = linkopts + get_hexagon_linkopts([
            "libcpp",
        ]),
        deps = deps,
        **kwargs
    )
