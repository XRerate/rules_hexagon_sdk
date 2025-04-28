package(default_visibility = ["//visibility:public"])

load(":cc_toolchain_config.bzl", "hexagon_cc_toolchain_config_rule")
load(":hexagon_envvars.bzl", "HEXAGON_ARCH")

cc_library(
    name = "headers",
    hdrs = glob([
        "incs/**/*.h",
        "incs/stddef/**/*.h",
    ]),
    includes = [
        "incs",
        "incs/stddef",
    ],
)

cc_library(
    name = "fastrpc_headers",
    hdrs = glob([
        "ipc/fastrpc/incs/**/*.h",
        "ipc/fastrpc/rpcmem/inc/**/*.h",
    ]),
    includes = [
        "ipc/fastrpc/incs",
        "ipc/fastrpc/rpcmem/inc",
    ],
)

filegroup(
    name = "cdsprpc",
    srcs = [
        "ipc/fastrpc/remote/ship/android_aarch64/libcdsprpc.so",
    ]
)

cc_library(
    name = "utils",
    srcs = [
        ":cdsprpc",
    ],
    deps = [
        ":fastrpc_headers",
        ":headers",
    ],
)

cc_library(
    name = "qurt_headers",
    hdrs = glob([
        "rtos/qurt/compute%s/include/posix/**/*.h" % HEXAGON_ARCH,
        "rtos/qurt/compute%s/include/qube/**/*.h" % HEXAGON_ARCH,
        "rtos/qurt/compute%s/include/qurt/**/*.h" % HEXAGON_ARCH,
    ]),
    includes = [
        "rtos/qurt/compute%s/include/posix" % HEXAGON_ARCH,
        "rtos/qurt/compute%s/include/qube" % HEXAGON_ARCH,
        "rtos/qurt/compute%s/include/qurt" % HEXAGON_ARCH,
    ],
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

hexagon_cc_toolchain_config_rule(
    name = "toolchain_config_hexagon",
    toolchain_identifier = "toolchain_config_hexagon",
)

toolchain(
    name = "hexagon_cc_toolchain",
    exec_compatible_with = [],
    target_compatible_with = [
        "@hexagonsdk//:hexagon",
    ],
    toolchain = ":cc_toolchain_hexagon",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

filegroup(
    name = "empty",
)

cc_toolchain(
    name = "cc_toolchain_hexagon",
    all_files = ":empty",
    ar_files = ":empty",
    as_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    toolchain_config = ":toolchain_config_hexagon",
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
