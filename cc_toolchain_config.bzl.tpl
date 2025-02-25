load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")


load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",    
    "flag_group", 
    "flag_set",   
    "tool_path",
)


all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

dynamic_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
]

static_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_static_library,
]



def construct_hexagon_flags(v_arch, sdk_root, lib_root, toolchain_root, no_wrap_mem_api = False):
    qurt_install_dir = "{}/rtos/qurt/compute{}".format(sdk_root, v_arch)
    rtos_dir = qurt_install_dir
    target_dir = "{}/{}/G0".format(lib_root, v_arch)
    target_dir_noos = "{}/Tools/target/hexagon/lib/{}".format(toolchain_root, v_arch)

    include_dirs = [
        "-I{}/include/posix".format(qurt_install_dir),
        "-I{}/include/qurt".format(qurt_install_dir),
        "-I{}/include".format(qurt_install_dir),
    ]
    
    # QURT Linker Flags
    # Defines a list of QURT libraries and object files needed for linking
    qurt_start_link_libs = [
        "{}/init.o".format(target_dir),
        "{}/lib/crt1.o".format(rtos_dir),
        "{}/lib/debugmon.o".format(rtos_dir),
        "{}/lib/libqurt.a".format(rtos_dir),
        "{}/libc.a".format(target_dir),
        "{}/libqcc.a".format(target_dir),
        "{}/libhexagon.a".format(target_dir),
        "{}/lib/libqurtcfs.a".format(rtos_dir),
        "{}/lib/libtimer_island.a".format(rtos_dir),
        "{}/lib/libtimer_main.a".format(rtos_dir),
        "{}/lib/pic/libposix.a".format(rtos_dir)
    ]

    qurt_end_link_libs = ["{}/fini.o".format(target_dir)]

    # QURT related linker flags
    exe_qurt_ld_flags = [
        "-m{}".format(v_arch),
        "-nodefaultlibs",
        "-nostdlib",
        "-Wl,-L{}/G0/".format(target_dir_noos),
        "-Wl,-L{}/Tools/target/hexagon/lib/".format(toolchain_root),
        "-Wl,--section-start",
        "-Wl,.interp=0x23000000",
        "-Wl,--dynamic-linker=",
        "-Wl,--force-dynamic",
        "-Wl,-E",
        "-Wl,-z",
        "-Wl,muldefs",
        "-Wl,--whole-archive",
        "-Wl,--start-group"
    ] + qurt_start_link_libs + qurt_end_link_libs + [
        "-Wl,--end-group"
    ]

    # Additional memory wrapping flags, if enabled
    if not no_wrap_mem_api:
        wrap_flags = [
            "-Wl,--wrap=malloc",
            "-Wl,--wrap=calloc",
            "-Wl,--wrap=free",
            "-Wl,--wrap=realloc",
            "-Wl,--wrap=memalign",
        ]


    # Shared library linker flags (PIC)
    pic_shared_ld_flags = [
        "-m{}".format(v_arch),
        "-G0",
        "-fpic",
        "-Wl,-Bsymbolic",
        "-Wl,-L{}/G0/pic".format(target_dir_noos),
        "-Wl,-L{}/Tools/target/hexagon/lib/".format(toolchain_root),
        "-Wl,--no-threads",
    ] + (wrap_flags if not no_wrap_mem_api else []) + [
        "-shared",
        "-lc",
    ]

    # Return all relevant flags in a dictionary
    return {
        "include_dirs": include_dirs,
        "exe_qurt_ld_flags": exe_qurt_ld_flags,
        "pic_shared_ld_flags": pic_shared_ld_flags,
    }

def hexagon_cc_toolchain_impl(ctx):

    HEXAGON_ARCH = ctx.var.get("HEXAGON_ARCH")
    HEXAGON_SDK_ROOT = ctx.var.get("HEXAGON_SDK_ROOT")
    HEXAGON_TOOLS_ROOT = ctx.var.get("HEXAGON_TOOLS_ROOT")
    HEXAGON_TOOLCHAIN = HEXAGON_TOOLS_ROOT
    HEXAGON_LIB_DIR = "{}/Tools/target/hexagon/lib".format(HEXAGON_TOOLCHAIN)
    _QURT_INSTALL_DIR = "{}/rtos/qurt/compute{}".format(HEXAGON_SDK_ROOT, HEXAGON_ARCH)

    COMMON_FLAGS = [
        "-m{}".format(HEXAGON_ARCH),
        "-G0",
        "-Wall",
        "-Werror",
        "-fno-zero-initialized-in-bss",
        "-fdata-sections",
        "-fpic",
        "-mhvx",
        "-mhvx-length=128B",
    ]

    hexagon_flags = construct_hexagon_flags(
        v_arch = HEXAGON_ARCH,
        sdk_root = HEXAGON_SDK_ROOT,
        lib_root = HEXAGON_LIB_DIR,
        toolchain_root = HEXAGON_TOOLCHAIN,
        no_wrap_mem_api = False, 
    )

    tool_paths = [
        tool_path(
            name = "gcc",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-clang",
        ),
        tool_path(
            name = "ld",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-clang",
        ),
        tool_path(
            name = "ar",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-ar",
        ),
        tool_path(
            name = "cpp",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-clang++",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-nm",
        ),
        tool_path(
            name = "objdump",
            path = "/bin/false",
        ),
        tool_path(
            name = "strip",
            path = HEXAGON_TOOLCHAIN + "/Tools/bin/hexagon-strip",
        ),
    ]
    features = [
        feature(
            name = "compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = ["c-compile", "c++-compile"],
                    flag_groups = [
                        flag_group(
                            flags= COMMON_FLAGS 
                            + hexagon_flags["include_dirs"]
                        )
                    ],
                ),
            ],
        ),
        feature(
            name = "linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = hexagon_flags["pic_shared_ld_flags"]                            
                        )
                    ]
                )
            ]
        ),

    ]
    return cc_common.create_cc_toolchain_config_info(
        ctx=ctx,
        features = features,
        cxx_builtin_include_directories = [
            HEXAGON_SDK_ROOT + "/incs",
            HEXAGON_SDK_ROOT + "/incs/stddef",
            HEXAGON_SDK_ROOT + "/incs/fastrpc/incs",
            _QURT_INSTALL_DIR + "/include",
            _QURT_INSTALL_DIR + "/include/qurt",
            _QURT_INSTALL_DIR + "/include/posix",
            _QURT_INSTALL_DIR + "/lib/pic",
            _QURT_INSTALL_DIR + "/lib",
            HEXAGON_LIB_DIR + "/pic",
            HEXAGON_TOOLS_ROOT + "/Tools/target/hexagon/include/"
        ],
        toolchain_identifier = "hexagon_toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "local",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )


cc_toolchain_config = rule(
    implementation = hexagon_cc_toolchain_impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
