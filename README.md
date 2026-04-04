# type2-runtime (Bazel)
![GitHub Actions](https://github.com/lalten/type2-runtime/actions/workflows/build.yaml/badge.svg)


> [!NOTE]
> This repository is a fork of <https://github.com/AppImage/type2-runtime> that uses Bazel as the build system.
It is used to build the runtime for <https://github.com/lalten/rules_appimage>.

The runtime is the executable part of every AppImage. It mounts the payload via FUSE and executes the entrypoint.
