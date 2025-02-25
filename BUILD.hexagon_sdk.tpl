package(default_visibility = ["//visibility:public"])

cc_library(
    name = "headers",
    hdrs = glob([
        "incs/*.h",
        "incs/**/*.h",
        "ipc/fastrpc/rpcmem/inc/*.h",
        "utils/examples/*.h",
    ]),
    includes = [
        "incs",
        "incs/stddef",
        "utils/examples",
    ],
)

filegroup(
    name = "dsp_capabilities_utils_srcs",
    srcs = [
        "utils/examples/dsp_capabilities_utils.c",
    ],
)

filegroup(
    name = "libcdsprpc",
    srcs = [
        "ipc/fastrpc/remote/ship/android_aarch64/libcdsprpc.so",
    ],
)

cc_library(
    name = "rpcmem_headers",
    srcs = [],
    hdrs = ["ipc/fastrpc/rpcmem/inc/rpcmem.h"],
    includes = ["ipc/fastrpc/rpcmem/inc/"],
)

cc_library(
    name = "qhl_headers",
    hdrs = glob([
        "libs/qhl/inc/**/*.h",
    ]),
    includes = [
        "libs/qhl/inc/qhblas",
        "libs/qhl/inc/qhcomplex",
        "libs/qhl/inc/qhdsp",
        "libs/qhl/inc/qhmath",
    ],
)

cc_library(
    name = "qhl_hvx_headers",
    srcs = [],
    hdrs = glob([
        "libs/qhl_hvx/inc/**/*.h",
    ]),
    includes = [
        "libs/qhl_hvx/inc/internal",
        "libs/qhl_hvx/inc/qhblas_hvx",
        "libs/qhl_hvx/inc/qhdsp_hvx",
        "libs/qhl_hvx/inc/qhmath_hvx",
    ],
)

cc_library(
    name = "worker_pool_headers",
    srcs = [],
    hdrs = glob([
        "libs/worker_pool/inc/*.h",
    ]),
    includes = ["libs/worker_pool/inc"],
)

load(":cc_toolchain_config.bzl", "cc_toolchain_config")

cc_toolchain_config(name = "hexagon_cc_toolchain_config")

toolchain(
    name = "cc_toolchain_for_hexagon",
    exec_compatible_with = [],
    target_compatible_with = [
        "@hexagonsdk//:hexagon",
    ],
    toolchain = ":hexagon_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

filegroup(
    name = "hexagon_toolchain_files",
)

cc_toolchain(
    name = "hexagon_toolchain",
    all_files = ":hexagon_toolchain_files",
    ar_files = ":hexagon_toolchain_files",
    as_files = ":hexagon_toolchain_files",
    compiler_files = ":hexagon_toolchain_files",
    dwp_files = ":hexagon_toolchain_files",
    linker_files = ":hexagon_toolchain_files",
    objcopy_files = ":hexagon_toolchain_files",
    strip_files = ":hexagon_toolchain_files",
    toolchain_config = ":hexagon_cc_toolchain_config",
    toolchain_identifier = "hexagon_toolchain",
)


constraint_value(
    name = "hexagon",
    constraint_setting = "@platforms//cpu",
)

platform(
    name = "hexagon_platform",
    constraint_values = [
        "@hexagonsdk//:hexagon",
    ],
)