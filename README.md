# LALWaveforms

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pseudofractal.github.io/LALWaveforms.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pseudofractal.github.io/LALWaveforms.jl/dev/)
[![Build Status](https://github.com/pseudofractal/LALWaveforms.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pseudofractal/LALWaveforms.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia package for GW waveform generation and detector response
built on top of [LALSuite](https://lscsoft.docs.ligo.org/lalsuite/7.26/index.html).

## Currently Implemented

- Generate time and frequency domain waveforms for a variety of waveform families.
- Compute detector response for a given detector configuration.
- Project gravitational wave polarizations onto detector strain.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/pseudofractal/LALWaveforms.jl")
```

## Development Environment

[Nix flake](https://wiki.nixos.org/wiki/Flakes) provided along with the
 project is the reconmended way to set up a development environment.
 To use it, you need to have [Nix](https://nixos.org/download.html)
 installed on your system.

You can enter the development environment by running:

```bash
nix develop
```

[direnv](https://direnv.net/) is also recommended to automatically
 load the development environment when you enter the project directory.

## LICENSE

MIT License. See [LICENSE](LICENSE) for details.
