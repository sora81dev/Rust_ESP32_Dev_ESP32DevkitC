{
  description = "ESP32-DevKitC Rust development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      runtimeLibraries = pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.zlib
        pkgs.zstd
        pkgs.openssl
        pkgs.libusb1
        pkgs.udev
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Rust / ESP
          rustup
          cargo-generate
          espup
          espflash
          ldproxy

          # ESP-IDF
          gcc
          cmake
          ninja
          pkg-config
          python3
          git

          # Runtime
          libusb1
          udev
        ];

        NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";

        NIX_LD_LIBRARY_PATH = runtimeLibraries;

        # bindgen -> esp-clang/libclang.so が libstdc++.so.6 を
        # dlopen 時に見つけるために必要
        LD_LIBRARY_PATH = runtimeLibraries;

        shellHook = ''
          echo "ESP32-DevKitC Rust development environment"
          echo

          if [ -f "$HOME/export-esp.sh" ]; then
            source "$HOME/export-esp.sh"
            echo "ESP Rust toolchain: loaded"
          else
            echo "ESP Rust toolchain: not installed"
            echo "Run: espup install"
          fi

          echo
          echo "Target: ESP32 / Xtensa"
        '';
      };
    };
}
