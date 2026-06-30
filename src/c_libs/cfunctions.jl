function _ntuple_to_string(x::NTuple{N,Cchar}) where {N}
  n = something(findfirst(iszero, x), N + 1) - 1
  return String(reinterpret(UInt8, collect(x[1:n])))
end

function XLALDestroyREAL8TimeSeries(series::Ptr{REAL8TimeSeries})
  ccall((:XLALDestroyREAL8TimeSeries, liblal), Cvoid, (Ptr{REAL8TimeSeries},), series)
end

function XLALDestroyCOMPLEX16FrequencySeries(series::Ptr{COMPLEX16FrequencySeries})
  ccall(
    (:XLALDestroyCOMPLEX16FrequencySeries, liblal),
    Cvoid,
    (Ptr{COMPLEX16FrequencySeries},),
    series,
  )
end

function XLALSimInspiralChooseTDWaveform(
  h₊::Ref{Ptr{REAL8TimeSeries}},
  hₓ::Ref{Ptr{REAL8TimeSeries}},
  m₁::Cdouble,
  m₂::Cdouble,
  S₁x::Cdouble,
  S₁y::Cdouble,
  S₁z::Cdouble,
  S₂x::Cdouble,
  S₂y::Cdouble,
  S₂z::Cdouble,
  distance::Cdouble,
  inclination::Cdouble,
  ϕ_ref::Cdouble,
  longAscNodes::Cdouble,
  eccentricity::Cdouble,
  meanPerAno::Cdouble,
  δt::Cdouble,
  f_min::Cdouble,
  f_ref::Cdouble,
  params::Ptr{Cvoid},
  approximant::Cint,
)
  ccall(
    (:XLALSimInspiralChooseTDWaveform, liblalsimulation),
    Cint,
    (
      Ref{Ptr{REAL8TimeSeries}},
      Ref{Ptr{REAL8TimeSeries}},
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Ptr{Cvoid},
      Cint,
    ),
    h₊,
    hₓ,
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
    ϕ_ref,
    longAscNodes,
    eccentricity,
    meanPerAno,
    δt,
    f_min,
    f_ref,
    params,
    approximant,
  )
end

function XLALSimInspiralChooseFDWaveform(
  h̃₊::Ref{Ptr{COMPLEX16FrequencySeries}},
  h̃ₓ::Ref{Ptr{COMPLEX16FrequencySeries}},
  m₁::Cdouble,
  m₂::Cdouble,
  S₁x::Cdouble,
  S₁y::Cdouble,
  S₁z::Cdouble,
  S₂x::Cdouble,
  S₂y::Cdouble,
  S₂z::Cdouble,
  distance::Cdouble,
  inclination::Cdouble,
  ϕ_ref::Cdouble,
  longAscNodes::Cdouble,
  eccentricity::Cdouble,
  meanPerAno::Cdouble,
  δf::Cdouble,
  f_min::Cdouble,
  f_max::Cdouble,
  f_ref::Cdouble,
  params::Ptr{Cvoid},
  approximant::Cint,
)
  ccall(
    (:XLALSimInspiralChooseFDWaveform, liblalsimulation),
    Cint,
    (
      Ref{Ptr{COMPLEX16FrequencySeries}},
      Ref{Ptr{COMPLEX16FrequencySeries}},
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Cdouble,
      Ptr{Cvoid},
      Cint,
    ),
    h̃₊,
    h̃ₓ,
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
    ϕ_ref,
    longAscNodes,
    eccentricity,
    meanPerAno,
    δf,
    f_min,
    f_max,
    f_ref,
    params,
    approximant,
  )
end

function XLALErrorString(code::Integer)
  ptr = ccall((:XLALErrorString, liblal), Cstring, (Cint,), code)
  ptr == C_NULL && return "Unknown XLAL error"
  return unsafe_string(ptr)
end

function XLALSimInspiralGetApproximantFromString(waveform::Cstring)
  return ccall(
    (:XLALSimInspiralGetApproximantFromString, liblalsimulation),
    Cint,
    (Cstring,),
    waveform,
  )
end

XLALGreenwichSiderealTime(gps::LIGOTimeGPS, equation_of_equinoxes::Cdouble) = ccall(
  (:XLALGreenwichSiderealTime, liblal),
  Cdouble,
  (Ptr{LIGOTimeGPS}, Cdouble),
  Ref(gps),
  equation_of_equinoxes,
)
