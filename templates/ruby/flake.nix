{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ruby' = pkgs.ruby_3_3;
        ruby_env = pkgs.bundlerEnv {
          name = "gems";
          ruby = ruby';
          gemdir = ./.;
          groups = [ "default" "production" "development" "test" ];
        };
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            formatter
            bundix
            pkg-config
            ruby'
            # ruby_env (pkgs.lib.lowPrio ruby_env.wrappedRuby)
          ];
          buildInputs = with pkgs; [
            libyaml
          ];
          shellHook = ''
            export MAKEFLAGS="-j$(nproc)" # make 'make' use all cores
            export MAKEOPTS="$MAKEFLAGS"
            export BUNDLE_FORCE_RUBY_PLATFORM=true # fix building gems with native extensions
            export RUBY_GEMS_BIN="$HOME/.local/share/gem/ruby/${ruby'.version.major}.${ruby'.version.minor}.0" # path gems for current ruby version
            export PATH="$RUBY_GEMS_BIN/bin:$PATH" # add binaries provided by gems to PATH
          '';
        };
      });
}
