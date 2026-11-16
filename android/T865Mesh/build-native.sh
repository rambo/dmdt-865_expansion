#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
project_root="$(pwd)"
sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$sdk_root" && -f local.properties ]]; then
    sdk_root=$(sed -n 's/^sdk.dir=//p' local.properties)
fi
if [[ -z "$sdk_root" ]]; then
    echo 'Set ANDROID_HOME or sdk.dir in local.properties.' >&2; exit 1
fi
ndk_root="$sdk_root/ndk/27.2.12479018"
case "$(uname -s)" in
    Darwin) ndk_host=darwin-x86_64;;
    Linux) ndk_host=linux-x86_64;;
    *) echo 'Build native library from macOS/Linux or WSL.' >&2; exit 1;;
esac
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$ndk_root/toolchains/llvm/prebuilt/$ndk_host/bin/aarch64-linux-android26-clang"
if [[ ! -x "$CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER" ]]; then echo "Missing NDK 27.2.12479018" >&2; exit 1; fi
export CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS="-C link-arg=-Wl,-z,max-page-size=16384"
export CARGO_TARGET_DIR="$project_root/../../rust/target"
cargo_bin="${CARGO:-$(command -v cargo || true)}"
if [[ -z "$cargo_bin" ]]; then cargo_bin="$HOME/.cargo/bin/cargo"; fi
"$cargo_bin" build --manifest-path ../../rust/Cargo.toml --locked --release --lib --target aarch64-linux-android
mkdir -p app/src/main/jniLibs/arm64-v8a
cp "$CARGO_TARGET_DIR/aarch64-linux-android/release/libt865_mesh.so" app/src/main/jniLibs/arm64-v8a/

"$ndk_root/toolchains/llvm/prebuilt/$ndk_host/bin/llvm-strip" --strip-unneeded app/src/main/jniLibs/arm64-v8a/libt865_mesh.so
