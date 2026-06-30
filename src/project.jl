"""
    project(detector, waveform, α, δ, ψ)

Project a gravitational-wave signal onto a detector.

Computes the strain measured by a detector for a gravitational wave
incident from the specified sky location and polarisation. The projection
uses the detector antenna pattern functions evaluated at the Greenwich
mean sidereal time corresponding to the waveform epoch.

This method is defined for both [`GWTimeSeries`](@ref) and
[`GWFrequencySeries`](@ref).

# Arguments

- `detector::Detector`: [`Detector`](@ref) receiving the signal.
- `waveform`: Gravitational-wave plus and cross polarisations stored as a [`GWTimeSeries`](@ref) or [`GWFrequencySeries`](@ref).
- `α::Real`: Right ascension of the source (rad).
- `δ::Real`: Declination of the source (rad).
- `ψ::Real`: Polarization angle (rad).

# Returns

Returns a detector strain with the same sampling as the input waveform.
Time-domain waveforms return a [`DetectorStrain`](@ref), while
frequency-domain waveforms return a
[`DetectorFrequencyStrain`](@ref).
"""
function project(detector::Detector, waveform::GWTimeSeries, α::Real, δ::Real, ψ::Real)
  θ = greenwich_sidereal_time(waveform.epoch)
  F₊, Fₓ = antenna_response(detector, α, δ, ψ, θ)
  h = similar(waveform.h₊)
  @. h = F₊ * waveform.h₊ + Fₓ * waveform.hₓ
  return DetectorStrain(h, waveform.δt, waveform.epoch, detector)
end

function project(detector::Detector, waveform::GWFrequencySeries, α::Real, δ::Real, ψ::Real)
  θ = greenwich_sidereal_time(waveform.epoch)
  F₊, Fₓ = antenna_response(detector, α, δ, ψ, θ)
  h̃ = similar(waveform.h̃₊)
  @. h̃ = F₊ * waveform.h̃₊ + Fₓ * waveform.h̃ₓ
  return DetectorFrequencyStrain(h̃, waveform.δf, waveform.epoch, detector)
end
