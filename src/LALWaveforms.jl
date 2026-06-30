module LALWaveforms

include("utlities.jl")
include("c_libs/ctypes.jl")
include("c_libs/cfunctions.jl")
include("types.jl")
include("datetime.jl")
include("approximants.jl")
include("inspiral.jl")
include("antenna.jl")
include("detectors.jl")
include("project.jl")

# Public API
export check_lalsuite

export Duration, GPSTime
export greenwich_sidereal_time, source_direction

export GWFrequencySeries, GWTimeSeries
export generate_fd_waveform, generate_td_waveform

export Approximant
export TaylorF1, TaylorF2, TaylorT1, TaylorT2, TaylorT3, TaylorT4
export IMRPhenomD, IMRPhenomD_NRTidalv2, IMRPhenomPv2, IMRPhenomXAS, IMRPhenomXP, IMRPhenomXPHM
export SEOBNRv4, SEOBNRv4P, SEOBNRv4PHM

export Arm, CachedDetector, Detector, DetectorType
export KAGRA, LHO_4K, LLO_4K, VIRGO
export antenna_response

export project

# C types for testing
export LALDetetor, LALDetectorType
end
