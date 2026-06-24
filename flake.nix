{
  description = "LALSimulation.jl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        # Core LAL
        lal = pkgs.stdenv.mkDerivation rec {
          pname = "lal";
          version = "7.7.0";
          src = pkgs.fetchurl {
            url = "http://software.igwn.org/lscsoft/source/lalsuite/${pname}-${version}.tar.xz";
            hash = "sha256-N6ar2hN+qDGb/01fMBitx5uwoAc0T4vVEqFBksz94Ss=";
          };
          nativeBuildInputs = [pkgs.pkg-config pkgs.python3];
          buildInputs = [pkgs.gsl pkgs.fftw pkgs.fftwFloat pkgs.hdf5 pkgs.zlib];
          configureFlags = [
            "--disable-python"
            "--disable-swig"
            "--with-hdf5=no"
          ];
        };

        # LALSimulation
        lalsimulation = pkgs.stdenv.mkDerivation rec {
          pname = "lalsimulation";
          version = "6.2.0";
          src = pkgs.fetchurl {
            url = "http://software.igwn.org/lscsoft/source/lalsuite/${pname}-${version}.tar.xz";
            hash = "sha256-SEYlwhiTQBOZryxfwIdRVp6ObCZdGNhZzGxEL7r/JrI=";
          };
          nativeBuildInputs = [pkgs.pkg-config pkgs.python3];
          buildInputs = [lal pkgs.gsl pkgs.fftw pkgs.fftwFloat pkgs.hdf5 pkgs.zlib];
          configureFlags = [
            "--disable-python"
            "--disable-swig"
          ];
        };

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.julia
            lalsimulation
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${lal}/lib:${lalsimulation}/lib:$LD_LIBRARY_PATH"
            echo "LAL Core compiled at: ${lal}"
            echo "LALSimulation compiled at: ${lalsimulation}"
          '';
        };
      }
    );
}
