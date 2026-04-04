load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")

ARCHS = [
    "x86_64",
    "aarch64",
]

[
    platform_transition_binary(
        name = "runtime_" + arch,
        binary = "//runtime",
        target_platform = "@toolchains_llvm_bootstrapped//platforms/libc_aware:linux_{}_musl".format(arch),
        visibility = ["//visibility:public"],
    )
    for arch in ARCHS
]

filegroup(
    name = "runtimes",
    srcs = [":runtime_" + arch for arch in ARCHS],
    visibility = ["//visibility:public"],
)
