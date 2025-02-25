""" Bazel extension for Hexagon SDK. """

load(":rules.bzl", "hexagon_sdk_repository")

def _hexagon_sdk_repository_extension_impl(ctx):
    """ Install the Hexagon SDK files. """

    hexagon_sdk_repository(
        name = "hexagonsdk",
    )

hexagon_sdk_repository_extension = module_extension(
    implementation = _hexagon_sdk_repository_extension_impl,
)
