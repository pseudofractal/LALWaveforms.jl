using Test
using PythonCall
using LALWaveforms

const lal = pyimport("lal")
const lalsim = pyimport("lalsimulation")

const MSUN = pyconvert(Float64, lal.MSUN_SI)
const PC_SI = pyconvert(Float64, lal.PC_SI)

f64(x) = pyconvert(Float64, x)
str(x) = pyconvert(String, x)
