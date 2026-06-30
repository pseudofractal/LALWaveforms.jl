function _unsafe_extract_timeseries(ptr::Ptr{REAL8TimeSeries})
  try
    ts::REAL8TimeSeries = unsafe_load(ptr)
    δt = ts.δt

    gps = ts.epoch
    epoch = GPSTime(gps.gpsSeconds, gps.gpsNanoSeconds)

    vecptr::Ptr{REAL8Sequence} = ts.data
    vec::REAL8Sequence = unsafe_load(vecptr)
    len::Int = Int(vec.length)
    data_ptr::Ptr{Float64} = vec.data

    h_wrapped::Vector{Float64} = Base.unsafe_wrap(Array, data_ptr, len; own = false)
    h_copy::Vector{Float64} = copy(h_wrapped)
    return h_copy, δt, epoch

  finally
    XLALDestroyREAL8TimeSeries(ptr)
  end
end

function _unsafe_extract_frequencyseries(ptr::Ptr{COMPLEX16FrequencySeries})
  try
    fs::COMPLEX16FrequencySeries = unsafe_load(ptr)
    δf = fs.δf

    gps = fs.epoch
    epoch = GPSTime(gps.gpsSeconds, gps.gpsNanoSeconds)

    vecptr::Ptr{COMPLEX16Sequence} = fs.data
    vec::COMPLEX16Sequence = unsafe_load(vecptr)
    len::Int = Int(vec.length)
    data_ptr::Ptr{ComplexF64} = vec.data

    h̃_wrapped::Vector{ComplexF64} = Base.unsafe_wrap(Array, data_ptr, len; own = false)
    h̃_copy::Vector{ComplexF64} = copy(h̃_wrapped)
    return h̃_copy, δf, epoch
  finally
    XLALDestroyCOMPLEX16FrequencySeries(ptr)
  end
end

"""
    generate_td_waveform(approximant, m₁, m₂; kwargs...)

Generate a time-domain gravitational waveform for a compact binary coalescence
using a LALSuite waveform model.

The returned [`GWTimeSeries`](@ref) contains the plus and cross polarisations,
``h_+`` and ``h_\\times``, sampled at a uniform cadence.

All inputs must be specified in SI units:

- masses in kilograms,
- distance in metres,
- frequencies in hertz,
- angles in radians.

# Arguments

- `approximant::Approximant`: The waveform model to use, chosen from the [`Approximant`](@ref) enum.
  Only approximants that are actually implemented in LALSimulation will
  produce a waveform. The full enum includes many historical placeholder values;
  using one that is not implemented will result in an error.

- `m₁::Real`: Mass of the first compact object (kg).

- `m₂::Real`: Mass of the second compact object (kg).

# Keyword Arguments

## Spin parameters

Dimensionless spin components in the source frame.

- `S₁x`, `S₁y`, `S₁z = 0.0`
- `S₂x`, `S₂y`, `S₂z = 0.0`

## Source geometry

- `distance = 1e6 * 3.085677581491367e16`: Luminosity distance to the source (1 Mpc).

- `inclination = 0.0`: Inclination angle between the orbital angular momentum and the
  line of sight.

- `ϕref = 0.0`: Orbital phase at the reference frequency `f_ref`.

- `longAscNodes = 0.0`: Longitude of the ascending node, defined as
  ``\\Omega - \\pi/2``.

## Orbital parameters

- `eccentricity = 0.0`: Orbital eccentricity at the reference epoch.

- `meanPerAno = 0.0`: Mean anomaly at the reference epoch (rad).

## Sampling and frequency settings

- `δT = 1 / 16384`: Sampling interval (s).

- `f_min = 40.0`: Starting gravitational-wave frequency (Hz).

- `f_ref = 0.0`: Reference gravitational-wave frequency (Hz). A value of `0`
  uses the default reference frequency chosen by the waveform model.

## Advanced

- `LALparams = C_NULL`: Pointer to a LAL dictionary containing additional waveform
  configuration parameters.

# Returns

A [`GWTimeSeries`](@ref) containing the plus and cross polarisations,
 ``h_+`` and ``h_\\times``, sampled at a uniform cadence.
"""
function generate_td_waveform(
  approximant::Approximant,
  m₁::Real,
  m₂::Real;
  S₁x::Real = 0.0,
  S₁y::Real = 0.0,
  S₁z::Real = 0.0,
  S₂x::Real = 0.0,
  S₂y::Real = 0.0,
  S₂z::Real = 0.0,
  distance::Real = 1e6 * 3.085677581491367e16, # 1 Mpc
  inclination::Real = 0.0,
  ϕref::Real = 0.0,
  longAscNodes::Real = 0.0,
  eccentricity::Real = 0.0,
  meanPerAno::Real = 0.0,
  δt::Real = 1.0 / 16384.0,
  f_min::Real = 40.0,
  f_ref::Real = 0.0,
  LALparams::Ptr{Cvoid} = C_NULL,
)
  check_lalsuite()

  approximant_id::Cint = Cint(approximant)

  h₊_ptr = Ref{Ptr{REAL8TimeSeries}}(C_NULL)
  hₓ_ptr = Ref{Ptr{REAL8TimeSeries}}(C_NULL)

  status::Cint = XLALSimInspiralChooseTDWaveform(
    h₊_ptr,
    hₓ_ptr,
    Cdouble(m₁),
    Cdouble(m₂),
    Cdouble(S₁x),
    Cdouble(S₁y),
    Cdouble(S₁z),
    Cdouble(S₂x),
    Cdouble(S₂y),
    Cdouble(S₂z),
    Cdouble(distance),
    Cdouble(inclination),
    Cdouble(ϕref),
    Cdouble(longAscNodes),
    Cdouble(eccentricity),
    Cdouble(meanPerAno),
    Cdouble(δt),
    Cdouble(f_min),
    Cdouble(f_ref),
    LALparams,
    approximant_id,
  )

  if status != 0
    msg = XLALErrorString(status)
    if h₊_ptr[] == C_NULL || hₓ_ptr[] == C_NULL
      error(
        "XLALSimInspiralChooseTDWaveform failed " * "(status = $(status), message = \"$(msg)\")",
      )
    else
      @warn("XLALSimInspiralChooseTDWaveform returned non-zero status", status, message = msg,)
    end
  end

  try
    h₊, δt₊, epoch₊ = _unsafe_extract_timeseries(h₊_ptr[])
    h₊_ptr[] = C_NULL

    hₓ, δtₓ, epochₓ = _unsafe_extract_timeseries(hₓ_ptr[])
    hₓ_ptr[] = C_NULL

    @assert abs(δt₊ - δtₓ) < 1e-15 * δt₊ "δt mismatch between polarisations"
    @assert epoch₊ == epochₓ "epoch mismatch between polarisations"

    return GWTimeSeries(h₊, hₓ, δt₊, epoch₊)

  finally
    if h₊_ptr[] != C_NULL
      XLALDestroyREAL8TimeSeries(h₊_ptr[])
    end
    if hₓ_ptr[] != C_NULL
      XLALDestroyREAL8TimeSeries(hₓ_ptr[])
    end
  end

end

"""
    generate_fd_waveform(approximant, m₁, m₂; kwargs...)

Generate a frequency-domain gravitational waveform for a compact binary coalescence
using a LALSuite waveform model.

The returned [`GWFrequencySeries`](@ref) contains the plus and cross polarisations,
``h̃_+`` and ``h̃_\\times``, sampled at a uniform frequency spacing.

All inputs must be specified in SI units:

- masses in kilograms,
- distance in metres,
- frequencies in hertz,
- angles in radians.

# Arguments

- `approximant::Approximant`: The waveform model to use, chosen from the [`Approximant`](@ref) enum.
  Only approximants that are actually implemented in LALSimulation will
  produce a waveform. The full enum includes many historical placeholder values;
  using one that is not implemented will result in an error.

- `m₁::Real`: Mass of the first compact object (kg).

- `m₂::Real`: Mass of the second compact object (kg).

# Keyword Arguments

## Spin parameters

Dimensionless spin components in the source frame.

- `S₁x`, `S₁y`, `S₁z = 0.0`
- `S₂x`, `S₂y`, `S₂z = 0.0`

## Source geometry

- `distance = 1e6 * 3.085677581491367e16`: Luminosity distance to the source (1 Mpc).

- `inclination = 0.0`: Inclination angle between the orbital angular momentum and the
  line of sight.

- `ϕref = 0.0`: Orbital phase at the reference frequency `f_ref`.

- `longAscNodes = 0.0`: Longitude of the ascending node, defined as
  ``\\Omega - \\pi/2``.

## Orbital parameters

- `eccentricity = 0.0`: Orbital eccentricity at the reference epoch.

- `meanPerAno = 0.0`: Mean anomaly at the reference epoch (rad).

## Sampling and frequency settings

- `δf = 1 / 16384`: Sampling interval (Hz).

- `f_min = 40.0`: Starting gravitational-wave frequency (Hz).

- `f_max = 0.0`: Ending gravitational-wave frequency (Hz). A value of `0` uses the
  default maximum frequency chosen by the waveform model.

- `f_ref = 0.0`: Reference gravitational-wave frequency (Hz). A value of `0`
  uses the default reference frequency chosen by the waveform model.

## Advanced

- `LALparams = C_NULL`: Pointer to a LAL dictionary containing additional waveform
  configuration parameters.

# Returns

A [`GWFrequencySeries`](@ref) containing the plus and cross polarisations,
 ``h̃_+`` and ``h̃_\\times``, sampled at a uniform frequency spacing.
"""
function generate_fd_waveform(
  approximant::Approximant,
  m₁::Real,
  m₂::Real;
  S₁x::Real = 0.0,
  S₁y::Real = 0.0,
  S₁z::Real = 0.0,
  S₂x::Real = 0.0,
  S₂y::Real = 0.0,
  S₂z::Real = 0.0,
  distance::Real = 1e6 * 3.085677581491367e16, # 1 Mpc
  inclination::Real = 0.0,
  ϕref::Real = 0.0,
  longAscNodes::Real = 0.0,
  eccentricity::Real = 0.0,
  meanPerAno::Real = 0.0,
  δf::Real = 1.0 / 16384.0,
  f_min::Real = 40.0,
  f_max::Real = 0.0,
  f_ref::Real = 0.0,
  LALparams::Ptr{Cvoid} = C_NULL,
)
  check_lalsuite()

  approximant_id::Cint = Cint(approximant)

  h̃₊_ptr = Ref{Ptr{COMPLEX16FrequencySeries}}(C_NULL)
  h̃ₓ_ptr = Ref{Ptr{COMPLEX16FrequencySeries}}(C_NULL)

  status::Cint = XLALSimInspiralChooseFDWaveform(
    h̃₊_ptr,
    h̃ₓ_ptr,
    m₁,
    m₂,
    S₁x,
    S₁y,
    S₁z,
    S₂x,
    S₂y,
    S₂z,
    distance,
    inclination,
    ϕref,
    longAscNodes,
    eccentricity,
    meanPerAno,
    δf,
    f_min,
    f_max,
    f_ref,
    LALparams,
    approximant_id,
  )

  if status != 0
    msg = XLALErrorString(status)
    if h̃₊_ptr[] == C_NULL || h̃ₓ_ptr[] == C_NULL
      error(
        "XLALSimInspiralChooseFDWaveform failed " * "(status = $(status), message = \"$(msg)\")",
      )
    else
      @warn("XLALSimInspiralChooseFDWaveform returned non-zero status", status, message = msg,)
    end
  end

  try
    h̃₊, δf₊, epoch₊ = _unsafe_extract_frequencyseries(h̃₊_ptr[])
    h̃₊_ptr[] = C_NULL

    h̃ₓ, δfₓ, epochₓ = _unsafe_extract_frequencyseries(h̃ₓ_ptr[])
    h̃ₓ_ptr[] = C_NULL

    @assert abs(δf₊ - δfₓ) < 1e-15 * δf₊ "δf mismatch between polarisations"
    @assert epoch₊ == epochₓ "epoch mismatch between polarisations"

    return GWFrequencySeries(h̃₊, h̃ₓ, δf₊, epoch₊)

  finally
    if h̃₊_ptr[] != C_NULL
      XLALDestroyCOMPLEX16FrequencySeries(h̃₊_ptr[])
    end
    if h̃ₓ_ptr[] != C_NULL
      XLALDestroyCOMPLEX16FrequencySeries(h̃ₓ_ptr[])
    end
  end
end
