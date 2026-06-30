import Base: *, +, -, /, <, <=, ==

"""
    GPSTime

Stores absolute GPS time to nanosecond precision. Converts to and from
[LIGOTimeGPS](https://lscsoft.docs.ligo.org/lalsuite/7.26/lal/group___l_a_l_datatypes.html#ss_LIGOTimeGPS).
"""
struct GPSTime
  s::Int32
  ns::Int32
end

"""
    Duration

Stores the precise time interval between two [`GPSTime`](@ref) values,
or a time shift to be applied to a `GPSTime`.
"""
struct Duration
  s::Int32
  ns::Int32
end

GPSTime(ns::Integer) = begin
  s, rem = fldmod(ns, 1_000_000_000)
  GPSTime(convert(Int32, s), convert(Int32, rem))
end
Duration(ns::Integer) = begin
  s, rem = fldmod(ns, 1_000_000_000)
  Duration(convert(Int32, s), convert(Int32, rem))
end

Base.show(io::IO, t::GPSTime) = print(io, "GPSTime($(t.s) s, $(t.ns) ns)")
Base.show(io::IO, d::Duration) = print(io, "Duration($(d.s) s, $(d.ns) ns)")

const AbstractTime = Union{GPSTime,Duration}

GPSTime(t::LIGOTimeGPS) = GPSTime(t.gpsSeconds, t.gpsNanoSeconds)
LIGOTimeGPS(t::GPSTime) = LIGOTimeGPS(t.s, t.ns)

Base.convert(::Type{T}, t::AbstractTime) where {T<:Real} = T(t.s) + T(t.ns) / T(1_000_000_000)
for T in (:Float16, :Float32, :Float64, :BigFloat)
  @eval Base.$T(t::AbstractTime) = convert($T, t)
end


_tons(t::AbstractTime) = Int64(t.s) * 1_000_000_000 + Int64(t.ns)
function _fromns(T::Type{<:AbstractTime}, total_ns::Int64)
  s = Int32(fld(total_ns, 1_000_000_000))
  ns = Int32(Base.mod(total_ns, 1_000_000_000))
  return T(s, ns)
end


==(t₁::T, t₂::T) where {T<:AbstractTime} = _tons(t₁) == _tons(t₂)
<(t₁::T, t₂::T) where {T<:AbstractTime} = _tons(t₁) < _tons(t₂)
<=(t₁::T, t₂::T) where {T<:AbstractTime} = _tons(t₁) <= _tons(t₂)
Base.isless(t₁::T, t₂::T) where {T<:AbstractTime} = _tons(t₁) < _tons(t₂)


-(t₁::GPSTime, t₂::GPSTime) = _fromns(Duration, _tons(t₁) - _tons(t₂))

+(t::GPSTime, d::Duration) = _fromns(GPSTime, _tons(t) + _tons(d))
+(d::Duration, t::GPSTime) = t + d
-(t::GPSTime, d::Duration) = _fromns(GPSTime, _tons(t) - _tons(d))

+(d₁::Duration, d₂::Duration) = _fromns(Duration, _tons(d₁) + _tons(d₂))
-(d₁::Duration, d₂::Duration) = _fromns(Duration, _tons(d₁) - _tons(d₂))
-(d::Duration) = _fromns(Duration, -_tons(d))

*(d::Duration, x::Real) = _fromns(Duration, round(Int64, _tons(d) * x))
*(x::Real, d::Duration) = d * x
/(d::Duration, x::Real) = _fromns(Duration, round(Int64, _tons(d) / x))

/(d₁::Duration, d₂::Duration) = _tons(d₁) / _tons(d₂)

Base.mod(t::AbstractTime, x::Real) = Base.mod(BigFloat(t), x)
Base.rem(t::AbstractTime, x::Real) = Base.rem(BigFloat(t), x)

# For running tests
Base.isapprox(t::AbstractTime, x::Real; kwargs...) = Base.isapprox(BigFloat(t), x; kwargs...)
Base.isapprox(x::Real, t::AbstractTime; kwargs...) = Base.isapprox(x, BigFloat(t); kwargs...)
Base.isapprox(t₁::AbstractTime, t₂::AbstractTime; kwargs...) =
  Base.isapprox(BigFloat(t₁), BigFloat(t₂); kwargs...)



# Some type jugulary that can possibly help me later
abstract type AbstractSeries end
abstract type AbstractTimeSeries <: AbstractSeries end
abstract type AbstractFrequencySeries <: AbstractSeries end

"""
    GWTimeSeries

Time-domain gravitational-wave strain data.

A `GWTimeSeries` stores the plus and cross polarisations,
``h_+`` and ``h_\\times``, sampled on a uniform time grid.

# Fields

- `h₊::AbstractVector{Real}`: Samples of the plus polarisation.
- `hₓ::AbstractVector{Real}`:Samples of the cross polarisation.
- `δt::Real`: Sampling interval in seconds.
- `epoch::GPSTime`: [`GPSTime`](@ref) of the first sample in seconds.
"""
struct GWTimeSeries{T<:Real,V<:AbstractVector{T}} <: AbstractTimeSeries
  h₊::V
  hₓ::V
  δt::T
  epoch::GPSTime
end
Base.show(io::IO, series::GWTimeSeries) = print(
  io,
  "GWTimeSeries {",
  "  h₊=$(series.h₊), ",
  "  hₓ=$(series.hₓ), ",
  "  δt=$(series.δt) s, ",
  "  epoch=$(series.epoch)",
  "}",
)

"""
    GWFrequencySeries
Frequency-domain gravitational-wave strain data.

A `GWFrequencySeries` stores the plus and cross polarisations,
``h̃_+`` and ``h̃_\\times``, sampled on a uniform frequency grid.

# Fields

- `h̃₊::AbstractVector{Complex}`: Samples of the plus polarisation.
- `h̃ₓ::AbstractVector{Complex}`: Samples of the cross polarisation.
- `δf::Real`: Frequency resolution in Hz.
- `epoch::GPSTime`: [`GPSTime`](@ref) of the first sample in seconds.
"""
struct GWFrequencySeries{T<:Complex,R<:Real,V<:AbstractVector{T}} <: AbstractFrequencySeries
  h̃₊::V
  h̃ₓ::V
  δf::R
  epoch::GPSTime
end
Base.show(io::IO, series::GWFrequencySeries) = print(
  io,
  "GWFrequencySeries {",
  "  h̃₊=$(series.h̃₊), ",
  "  h̃ₓ=$(series.h̃ₓ), ",
  "  δf=$(series.δf) Hz, ",
  "  epoch=$(series.epoch)",
  "}",
)

"""
    DetectorResponse

Symmetric detector response tensor.

A `DetectorResponse` stores the symmetric rank-2 tensor describing the
response of a gravitational-wave detector ([`Detector`](@ref)). The tensor encodes the
detector geometry and is used to compute antenna pattern functions and
project gravitational-wave polarisations onto the detector.

# Fields

- `xx::Real`: xx component of the response tensor.
- `xy::Real`: xy component of the response tensor.
- `xz::Real`: xz component of the response tensor.
- `yy::Real`: yy component of the response tensor.
- `yz::Real`: yz component of the response tensor.
- `zz::Real`: zz component of the response tensor.
"""
struct DetectorResponse{T<:Real}
  xx::T
  xy::T
  xz::T
  yy::T
  yz::T
  zz::T
end

DetectorResponse(A::AbstractMatrix{T}) where {T<:Real} = begin
  @boundscheck size(A) == (3, 3) || throw(ArgumentError("Matrix must be 3x3"))
  A[1, 2] == A[2, 1] && A[1, 3] == A[3, 1] && A[2, 3] == A[3, 2] ||
    throw(ArgumentError("Matrix must be symmetric"))
  DetectorResponse{T}(A[1, 1], A[1, 2], A[1, 3], A[2, 2], A[2, 3], A[3, 3])
end
Base.convert(::Type{Matrix{T}}, R::DetectorResponse{T}) where {T<:Real} = [
  R.xx R.xy R.xz
  R.xy R.yy R.yz
  R.xz R.yz R.zz
]

Base.getindex(R::DetectorResponse, i::Int, j::Int) = begin
  @boundscheck (1 ≤ i ≤ 3 && 1 ≤ j ≤ 3) || throw(BoundsError(R, (i, j)))
  if i > j
    i, j = j, i
  end
  if i == 1
    return j == 1 ? R.xx : j == 2 ? R.xy : R.xz
  elseif i == 2
    return j == 2 ? R.yy : R.yz
  else
    return R.zz
  end
end
Base.size(::DetectorResponse) = (3, 3)
Base.show(io::IO, R::DetectorResponse{T}) where {T<:Real} = print(io, convert(Matrix{T}, R))

"""
    Arm

Detector arm geometry.

An `Arm` describes the orientation and midpoint of an interferometer arm.
The arm geometry is used to construct the detector response tensor from
the detector location and orientation.

# Fields

- `altitude::Real`: Altitude angle above the local horizontal (rad).
- `azimuth::Real`: Azimuth measured east of north (rad).
- `midpoint::Real`: Distance from the detector vertex to the arm midpoint (m).
"""
struct Arm{T<:Real}
  altitude::T
  azimuth::T
  midpoint::T
end
Base.show(io::IO, arm::Arm) = print(
  io,
  "Arm {",
  "  altitude=$(arm.altitude) rad, ",
  "  azimuth=$(arm.azimuth) rad, ",
  "  midpoint=$(arm.midpoint) m",
  "}",
)

"""
    DetectorType

Enumeration of supported gravitational-wave detector configurations.

`DetectorType` specifies how a detector responds to an incident
gravitational wave. The detector type determines how the detector
response tensor is constructed from the detector geometry.

# Values

- `DifferentialIFO`: Differential interferometer.
- `XArmIFO`: Single-arm interferometer using the x arm.
- `YArmIFO`: Single-arm interferometer using the y arm.
- `CommonIFO`: Common-mode interferometer.
- `CylindricalBar`: Cylindrical resonant-bar detector.
"""
@enum DetectorType begin
  DifferentialIFO = Int(IFODiff)
  XArmIFO = Int(IFOXArm)
  YArmIFO = Int(IFOYArm)
  CommonIFO = Int(IFOComm)
  CylindricalBar = Int(CylBar)
end
DetectorType(t::LALDetectorType) = DetectorType(Int(t))
LALDetectorType(t::DetectorType) = LALDetectorType(Int(t))

"""
    Detector

Gravitational-wave detector.

A `Detector` stores the geometry and location of a gravitational-wave
detector. It contains the detector position on the Earth, the arm
geometry([`Arm`](@ref)), and the precomputed detector response tensor
used for antenna pattern and strain projection calculations.

# Fields

- `name::String`: Full detector name.
- `prefix::String`: Short detector identifier.
- `longitude::Real`: Geodetic longitude (rad).
- `latitude::Real`: Geodetic latitude (rad).
- `elevation::Real`: Elevation above the WGS-84 reference ellipsoid (m).
- `location::NTuple{3, Real}`: Earth-centered, Earth-fixed Cartesian coordinates (m).
- `response::DetectorResponse`: [`DetectorResponse`](@ref) tensor.
- `xarm::Arm`: Geometry of the X [`Arm`](@ref).
- `yarm::Arm`: Geometry of the Y [`Arm`](@ref).
- `type::DetectorType`: Detector operating mode ([`DetectorType`](@ref)).
"""
struct Detector{T<:Real}
  name::String
  prefix::String
  longitude::T
  latitude::T
  elevation::T
  location::NTuple{3,T}
  response::DetectorResponse{T}
  xarm::Arm{T}
  yarm::Arm{T}
  type::DetectorType
end
Base.show(io::IO, detector::Detector) = print(
  io,
  "Detector {",
  "  name=$(detector.name), ",
  "  prefix=$(detector.prefix), ",
  "  longitude=$(detector.longitude) rad, ",
  "  latitude=$(detector.latitude) rad, ",
  "  elevation=$(detector.elevation) m, ",
  "  location=$(detector.location), ",
  "  response=$(detector.response), ",
  "  xarm=$(detector.xarm), ",
  "  yarm=$(detector.yarm), ",
  "  type=$(detector.type)",
  "}",
)

"""
    DetectorStrain

Time-domain gravitational-wave strain measured by a detector.

A `DetectorStrain` represents the response of a single gravitational-wave
detector to an incident gravitational wave. The strain is obtained by
projecting the plus and cross polarisations of a
[`GWTimeSeries`](@ref) onto the detector tensor using the detector's
antenna response.

The stored strain is dimensionless and sampled uniformly in time.

# Fields

- `h::AbstractVector{Real}`: Measured detector strain.
- `δt::Real`: Sampling interval.
- `epoch::GPSTime`: [`GPSTime`](@ref) of the first sample.
- `detector::Detector`: [`Detector`](@ref) at which the strain was evaluated.
"""
struct DetectorStrain{T<:Real,V<:AbstractVector{T},D<:Detector} <: AbstractTimeSeries
  h::V
  δt::T
  epoch::GPSTime
  detector::D
end

"""
    DetectorFrequencyStrain

Frequency-domain gravitational-wave strain measured by a detector.

A `DetectorFrequencyStrain` represents the response of a single
gravitational-wave detector to an incident gravitational wave in the
frequency domain. The strain is obtained by projecting the plus and
cross polarisations of a [`GWFrequencySeries`](@ref) onto the detector
tensor using the detector's antenna response.

The stored strain is dimensionless and sampled on a uniform frequency
grid.

# Fields

- `h̃::AbstractVector{Complex}`: Measured detector strain.
- `δf::Real`: Frequency resolution.
- `epoch::GPSTime`: [`GPSTime`](@ref) of the first sample.
- `detector::Detector`: [`Detector`](@ref) at which the strain was evaluated.
"""
struct DetectorFrequencyStrain{T<:Complex,R<:Real,V<:AbstractVector{T},D<:Detector} <:
       AbstractFrequencySeries
  h̃::V
  δf::R
  epoch::GPSTime
  detector::D
end
