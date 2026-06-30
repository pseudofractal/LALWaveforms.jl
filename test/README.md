# Testing

All important functions are validated against [lalsuite](https://pypi.org/project/lalsuite/) python library,
 using the [PythonCall](https://github.com/JuliaPy/PythonCall.jl) package.

Python dependencies for the same are managed used [uv](https://docs.astral.sh/uv/).

Going through the [nix flake](https://wiki.nixos.org/wiki/Flakes) hoop is
 recommended to setup the development envrionment.

To test the code, run the following command in the project root directory:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```
