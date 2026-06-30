"""
    greenwich_sidereal_time(time, equation_of_equinoxes = 0.0)

Returns the Greenwich Sidereal Time (GST) corresponding to a specified GPS time.

By default (`equation_of_equinoxes = 0.0`), this calculates the Greenwich Mean Sidereal Time. 
Apparent sidereal time is computed by providing the equation of the equinoxes.

This is a direct wrapper around LALSuite's [`XLALGreenwichSiderealTime`](https://lscsoft.docs.ligo.org/lalsuite/7.26/lal/group___x_l_a_l_sideral_time__c.html#ga346613e65db0a7d454a71260fc3de4ae).

# Arguments
* `time::GPSTime`: The absolute [`GPSTime`](@ref) to evaluate.
* `equation_of_equinoxes::Float64`: (Optional) The equation of the equinoxes, strictly in seconds of time. Defaults to `0.0`.

# Returns
Returns the sidereal time in radians as a `Float64`, measured from the Julian epoch (J2000). Note: The result is NOT modulo `2π`. 
"""
greenwich_sidereal_time(time::GPSTime, equation_of_equinoxes::Float64 = 0.0) =
  XLALGreenwichSiderealTime(LIGOTimeGPS(time), equation_of_equinoxes)

"""
    source_direction

Returns the Earth-fixed unit vector pointing from the geocenter toward a source
at right ascension `α` and declination `δ` evaluated at the given GPS time.

# Arguments
* `α::Real`: The right ascension of the source in radians.
* `δ::Real`: The declination of the source in radians.
* `time::GPSTime`: [`GPSTime`](@ref) at which to evaluate the source direction.

# Returns
Returns a tuple `(x, y, z)` representing the unit vector in the Earth-fixed frame.
"""
source_direction(α::Real, δ::Real, time::GPSTime) = begin
  gha = greenwich_sidereal_time(time) - α
  sin_gha, cos_gha = sincos(gha)
  sinδ, cosδ = sincos(δ)
  (cosδ * cos_gha, -cosδ * sin_gha, sinδ)
end

"""
    arrival_time_difference(det₁, det₂, α, δ, time)

Returns the difference in gravitational-wave arrival time between two detectors.

The returned value is positive when the wavefront reaches `detector1`
*after* `detector2`.

# Arguments
- `det₁::Detector`: First [`Detector`](@ref).
- `det₂::Detector`: Second [`Detector`](@ref).
- `α::Real`: Source right ascension (radians).
- `δ::Real`: Source declination (radians).
- `time::GPSTime`: [`GPSTime`](@ref) at which to evaluate the source position.

# Returns
Returns the arrival time difference in seconds.
"""
arrival_time_difference(det₁::Detector, det₂::Detector, α::Real, δ::Real, time::GPSTime) = begin
  nx, ny, nz = source_direction(α, δ, time)
  x₁, y₁, z₁ = det₁.location
  x₂, y₂, z₂ = det₂.location
  (nx * (x₂ - x₁) + ny * (y₂ - y₁) + nz * (z₂ - z₁)) / SPEED_OF_LIGHT
end

"""
    time_delay(detector, α, δ, time)

Returns the gravitational-wave arrival time at a detector relative to the
Earth's center.

A positive value indicates that the wavefront reaches the detector after
reaching the geocenter.

This is the Earth-center special case of [`arrival_time_difference`](@ref).

# Arguments
* `detector::Detector`: The [`Detector`](@ref).
* `α::Real`: Source right ascension in radians.
* `δ::Real`: Source declination in radians.
* `time::GPSTime`: The absolute [`GPSTime`](@ref) at which to evaluate.

# Returns
Returns the arrival time delay in seconds.
"""
time_delay(detector::Detector, α::Real, δ::Real, time::GPSTime) = begin
  nx, ny, nz = source_direction(α, δ, time)
  x, y, z = detector.location
  -(nx*x + ny*y + nz*z) / SPEED_OF_LIGHT
end
