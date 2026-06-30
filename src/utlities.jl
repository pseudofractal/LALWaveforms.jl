using Libdl

const _checked_lalsuite = Ref(false)

"""
    check_lalsuite()

Verify that the required LALSuite shared libraries can be loaded.

This function checks that both `liblal` and `liblalsimulation` are
available to Julia's dynamic linker. If either library cannot be
loaded, an error is thrown with diagnostic information describing the
missing dependency.

This check is performed automatically by waveform-generation routines,
but may also be called directly to diagnose installation issues.
"""
function check_lalsuite()
  _checked_lalsuite[] && return nothing
  try
    Libdl.dlopen(liblal)
  catch err
    error("""
    Failed to load the LALSuite core library `liblal`.

    Ensure that LALSuite is installed and that `liblal` is visible
    to Julia's dynamic linker.

    Original error:
    $err
    """)
  end
  try
    Libdl.dlopen(liblalsimulation)
  catch err
    error("""
    Failed to load the LALSimulation library `liblalsimulation`.

    Ensure that LALSimulation is installed and that
    `liblalsimulation` is visible to Julia's dynamic linker.

    Original error:
    $err
    """)
  end
  _checked_lalsuite[] = true
  return nothing
end

const SPEED_OF_LIGHT = 299_792_458.0 # m/s
