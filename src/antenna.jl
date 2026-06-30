"""
    antenna_response(detector, α, δ, ψ, θ_GMST)

Compute the antenna pattern functions ``F_+`` and ``F_\\times`` for a
gravitational-wave detector. An implementation of the detector response formula
in [Anderson et al (2001)](https://arxiv.org/pdf/gr-qc/0008066).

# Arguments

- `detector::Detector`: [`Detector`](@ref).
- `α`: Right ascension (rad).
- `δ`: Declination (rad).
- `ψ`: Polarization angle (rad).
- `θ_GMST`: Greenwich mean sidereal time (rad).

# Returns

A tuple `(F₊, Fₓ)` containing the plus and cross antenna pattern
functions.
"""
function antenna_response(
  detector::Detector{T},
  α::Real,
  δ::Real,
  ψ::Real,
  θ_GMST::Real,
) where {T<:Real}

  R = detector.response

  H = θ_GMST - α

  sinH, cosH = sincos(H)
  sinδ, cosδ = sincos(δ)
  sinψ, cosψ = sincos(ψ)

  X₁ = -sinH * cosψ - sinψ * cosH * sinδ
  X₂ = -cosH * cosψ + sinψ * sinH * sinδ
  X₃ = sinψ * cosδ

  Y₁ = sinψ * sinH - cosψ * cosH * sinδ
  Y₂ = sinψ * cosH + cosψ * sinH * sinδ
  Y₃ = cosψ * cosδ

  DX₁ = R[1, 1] * X₁ + R[1, 2] * X₂ + R[1, 3] * X₃
  DX₂ = R[2, 1] * X₁ + R[2, 2] * X₂ + R[2, 3] * X₃
  DX₃ = R[3, 1] * X₁ + R[3, 2] * X₂ + R[3, 3] * X₃

  DY₁ = R[1, 1] * Y₁ + R[1, 2] * Y₂ + R[1, 3] * Y₃
  DY₂ = R[2, 1] * Y₁ + R[2, 2] * Y₂ + R[2, 3] * Y₃
  DY₃ = R[3, 1] * Y₁ + R[3, 2] * Y₂ + R[3, 3] * Y₃

  F₊ = X₁ * DX₁ - Y₁ * DY₁ + X₂ * DX₂ - Y₂ * DY₂ + X₃ * DX₃ - Y₃ * DY₃

  Fₓ = X₁ * DY₁ + Y₁ * DX₁ + X₂ * DY₂ + Y₂ * DX₂ + X₃ * DY₃ + Y₃ * DX₃

  return F₊, Fₓ
end
