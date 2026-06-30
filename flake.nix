{
  description = "LALSimulation.jl: A Julia package for GW waveform generation and detector response built on top of LALSuite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
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
          nativeBuildInputs = [pkgs.pkg-config];
          buildInputs = [pkgs.gsl pkgs.fftw pkgs.fftwFloat pkgs.zlib];
          configureFlags = [
            "--disable-swig"
            "--disable-python"
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
          nativeBuildInputs = [pkgs.pkg-config];
          buildInputs = [lal pkgs.gsl pkgs.fftw pkgs.fftwFloat pkgs.zlib];
          configureFlags = [
            "--disable-swig"
            "--disable-python"
          ];
          propagatedBuildInputs = [lal];
        };
      in {
        packages = {
          inherit lal lalsimulation;
          default = lalsimulation;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.julia
            lal
            lalsimulation

            # For testing required by `PythonCall`
            pkgs.uv
            pkgs.python311
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${lal}/lib:${lalsimulation}/lib:$LD_LIBRARY_PATH"
            echo "LAL Core compiled at: ${lal}"
            echo "LALSimulation compiled at: ${lalsimulation}"

            # For testing required by `PythonCall`
            export JULIA_PYTHONCALL_EXE="/home/pseudofractal/GitHub/LALWaveforms.jl/test/.venv/bin/python"
            export JULIA_CONDAPKG_BACKEND="Null"
          '';
        };
      }
    );
}
