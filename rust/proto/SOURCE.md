# Archived Meshtastic protobuf source

Retrieved 2026-11-16 from the complete `.proto` tree at:

`https://github.com/meshtastic/protobufs/tree/cf0a84ede1e7a0b7479e90a5e496d30c5dfba707`

This is the protobuf submodule revision pinned by reference firmware
`6d41e279f1f51bd59f687b9d441c1bf47b1594fc`. Builds use these local source files;
there is no Git branch or network schema fetch in the build. `prost-build`
compiles `meshtastic/mesh.proto` and its dependencies using the compiler pinned
in Cargo.lock. The upstream [LICENSE](LICENSE) is retained.
