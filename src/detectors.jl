"""
    CachedDetector

Selected redefined gravitational wave detectors, 
contained in the [lalCachedDetectors](https://lscsoft.docs.ligo.org/lalsuite/7.26/lal/group___l_a_l_detectors__h.html#ggadc329d460698e1676c4670b972d202c0aca23d5108de2e54895697c23c6fa9043) array.
"""
@enum CachedDetector::Int32 begin
  TAMA_300 = 0
  VIRGO_CITF = 1
  VIRGO = 2
  GEO_600 = 3
  LHO_2K = 4
  LHO_4K = 5
  LLO_4K = 6
  CIT_40 = 7
  ALLEGRO_320 = 8
  AURIGA = 9
  EXPLORER = 10
  NIOBE = 11
  NAUTILUS = 12
  ACIGA = 13
  KAGRA = 14
  LIO_4K = 15
  ET1 = 16
  ET2 = 17
  ET3 = 18
  ET0 = 19
end

Detector(det::LALDetector) = begin
  fr = det.frDetector
  Detector(
    _ntuple_to_string(fr.name),
    _ntuple_to_string(fr.prefix),
    Float64(fr.vertexLongitudeRadians),
    Float64(fr.vertexLatitudeRadians),
    Float64(fr.vertexElevation),
    (Float64(det.location[1]), Float64(det.location[2]), Float64(det.location[3])),
    DetectorResponse(
      Float64(det.detector_response[1][1]),
      Float64(det.detector_response[1][2]),
      Float64(det.detector_response[1][3]),
      Float64(det.detector_response[2][2]),
      Float64(det.detector_response[2][3]),
      Float64(det.detector_response[3][3]),
    ),
    Arm(Float64(fr.xArmAltitudeRadians), Float64(fr.xArmAzimuthRadians), Float64(fr.xArmMidpoint)),
    Arm(Float64(fr.yArmAltitudeRadians), Float64(fr.yArmAzimuthRadians), Float64(fr.yArmMidpoint)),
    DetectorType(det.type),
  )
end

Detector(det::CachedDetector) = Detector(unsafe_load(cached_detectors_ptr(), Int(det) + 1))

function _cartesian_components(altitude::Real, azimuth::Real, latitude::Real, longitude::Real)
  sinAlt, cosAlt = sincos(altitude)
  sinAz, cosAz = sincos(azimuth)
  sinLat, cosLat = sincos(latitude)
  sinLon, cosLon = sincos(longitude)

  uNorth = cosAlt * cosAz
  uEast = cosAlt * sinAz
  uRho = -sinLat * uNorth + cosLat * sinAlt

  return (
    cosLon * uRho - sinLon * uEast,
    sinLon * uRho + cosLon * uEast,
    cosLat * uNorth + sinLat * sinAlt,
  )
end


function _compute_location(latitude::Real, longitude::Real, elevation::Real)
  WGS84_A = 6378137.0 # Semimajor axis of WGS-84 Reference Ellipsoid, m
  WGS84_B = 6356752.314 # Semiminor axis of WGS-84 Reference Ellipsoid, m
  sinLat, cosLat = sincos(latitude)
  sinLon, cosLon = sincos(longitude)
  den = sqrt(WGS84_A^2 * cosLat^2 + WGS84_B^2 * sinLat^2)
  ρ = cosLat * (WGS84_A^2 / den + elevation)
  return (ρ * cosLon, ρ * sinLon, sinLat * (WGS84_B^2 / den + elevation))
end

function _compute_response(
  latitude::T,
  longitude::T,
  xarm::Arm{T},
  yarm::Arm{T},
  type::DetectorType,
) where {T<:Real}

  if type == DifferentialIFO
    x = _cartesian_components(xarm.altitude, xarm.azimuth, latitude, longitude)
    y = _cartesian_components(yarm.altitude, yarm.azimuth, latitude, longitude)
    return DetectorResponse(
      (x[1]^2 - y[1]^2) / 2,
      (x[1] * x[2] - y[1] * y[2]) / 2,
      (x[1] * x[3] - y[1] * y[3]) / 2,
      (x[2]^2 - y[2]^2) / 2,
      (x[2] * x[3] - y[2] * y[3]) / 2,
      (x[3]^2 - y[3]^2) / 2,
    )

  elseif type == XArmIFO
    x = _cartesian_components(xarm.altitude, xarm.azimuth, latitude, longitude)
    return DetectorResponse(
      x[1]^2 / 2,
      x[1] * x[2] / 2,
      x[1] * x[3] / 2,
      x[2]^2 / 2,
      x[2] * x[3] / 2,
      x[3]^2 / 2,
    )

  elseif type == YArmIFO
    y = _cartesian_components(yarm.altitude, yarm.azimuth, latitude, longitude)
    return DetectorResponse(
      y[1]^2 / 2,
      y[1] * y[2] / 2,
      y[1] * y[3] / 2,
      y[2]^2 / 2,
      y[2] * y[3] / 2,
      y[3]^2 / 2,
    )

  elseif type == CommonIFO
    x = _cartesian_components(xarm.altitude, xarm.azimuth, latitude, longitude)
    y = _cartesian_components(yarm.altitude, yarm.azimuth, latitude, longitude)
    return DetectorResponse(
      (x[1]^2 + y[1]^2) / 2,
      (x[1] * x[2] + y[1] * y[2]) / 2,
      (x[1] * x[3] + y[1] * y[3]) / 2,
      (x[2]^2 + y[2]^2) / 2,
      (x[2] * x[3] + y[2] * y[3]) / 2,
      (x[3]^2 + y[3]^2) / 2,
    )

  elseif type == CylindricalBar
    x = _cartesian_components(xarm.altitude, xarm.azimuth, latitude, longitude)
    return DetectorResponse(x[1]^2, x[1] * x[2], x[1] * x[3], x[2]^2, x[2] * x[3], x[3]^2)

  else
    throw(ArgumentError("Unknown detector type: $type"))
  end
end

Arm(altitude::Real, azimuth::Real, midpoint::Real = 0) = begin
  T = promote_type(typeof(altitude), typeof(azimuth), typeof(midpoint))
  Arm{T}(T(altitude), T(azimuth), T(midpoint))
end

function Detector(;
  name::AbstractString,
  latitude::Real,
  longitude::Real,
  xarm::Arm,
  yarm::Arm,
  elevation::Real = 0,
  prefix::AbstractString = name,
  type::DetectorType = DifferentialIFO,
)
  T = promote_type(
    typeof(latitude),
    typeof(longitude),
    typeof(elevation),
    typeof(xarm.altitude),
    typeof(xarm.azimuth),
    typeof(xarm.midpoint),
    typeof(yarm.altitude),
    typeof(yarm.azimuth),
    typeof(yarm.midpoint),
  )
  xarm = Arm{T}(T(xarm.altitude), T(xarm.azimuth), T(xarm.midpoint))
  yarm = Arm{T}(T(yarm.altitude), T(yarm.azimuth), T(yarm.midpoint))
  location = _compute_location(latitude, longitude, elevation)
  response = _compute_response(latitude, longitude, xarm, yarm, type)
  return Detector{T}(
    String(name),
    String(prefix),
    T(longitude),
    T(latitude),
    T(elevation),
    location,
    response,
    xarm,
    yarm,
    type,
  )
end
