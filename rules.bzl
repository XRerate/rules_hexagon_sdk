""" Bazel rules for Hexagon SDK. """

def _hexagon_sdk_repository_impl(ctx):
    """ Install the Hexagon SDK files. """

    sdk_root = _get_envvar_or_fail(ctx, "HEXAGON_SDK_ROOT")
    tools_root = _get_envvar_or_fail(ctx, "HEXAGON_TOOLS_ROOT")
    arch = _get_envvar_or_fail(ctx, "HEXAGON_ARCH")
    tools_version = _get_envvar_or_fail(ctx, "HEXAGON_TOOLS_VERSION")
    tools_arch_version = _get_envvar_or_fail(ctx, "HEXAGON_TOOLS_ARCH_VERSION")

    ctx.template(
        "hexagon_envvars.bzl",
        ctx.attr._template_envvars,
        {
            "{HEXAGON_SDK_ROOT}": sdk_root,
            "{HEXAGON_TOOLS_ROOT}": tools_root,
            "{HEXAGON_ARCH}": arch,
            "{HEXAGON_TOOLS_VERSION}": tools_version,
            "{HEXAGON_TOOLS_ARCH_VERSION}": tools_arch_version,
        },
        executable = False,
    )

    ctx.template(
        "build_defs.bzl",
        ctx.attr._template_builddefs,
        {},
        executable = False,
    )

    ctx.template(
        "BUILD",
        ctx.attr._template_sdk,
        {},
        executable = False,
    )

    ctx.template(
        "cc_toolchain_config.bzl",
        ctx.attr._template_toolchain,
        {},
        executable = False,
    )

    if not sdk_root.endswith("/"):
        sdk_root = sdk_root + "/"

    # Create synlinks to the SDK files.
    target_dirs = ["incs", "ipc", "libs", "utils"]
    for p in ctx.path(sdk_root).readdir():
        # p is path
        if p.basename not in target_dirs:
            continue
        repo_relative_path = str(p).replace(sdk_root, "")
        ctx.symlink(p, repo_relative_path)

def _get_envvar_or_fail(ctx, name):
    value = ctx.os.environ.get(name, None)
    if not value:
        fail("The environment variable '{}' must be set.".format(name))
    return value

hexagon_sdk_repository = repository_rule(
    attrs = {
        "_template_sdk": attr.label(default = ":BUILD.hexagon_sdk.tpl", allow_single_file = True),
        "_template_envvars": attr.label(default = ":hexagon_envvars.bzl.tpl", allow_single_file = True),
        "_template_toolchain": attr.label(default = ":cc_toolchain_config.bzl.tpl", allow_single_file = True),
        "_template_builddefs": attr.label(default = ":build_defs.bzl.tpl", allow_single_file = True),
    },
    implementation = _hexagon_sdk_repository_impl,
)
