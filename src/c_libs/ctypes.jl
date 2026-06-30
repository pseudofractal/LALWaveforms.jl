const liblal = "liblal"
const liblalsimulation = "liblalsimulation"

# Both these magic values can be found in `LALDatatypes.h`
const LALNameLength = 64
const LALNumUnits = 7

struct LIGOTimeGPS
  gpsSeconds::Int32
  gpsNanoSeconds::Int32
end

struct LALUnit
  powerOfTen::Int16
  unitNumerator::NTuple{LALNumUnits,Int16}
  unitDenominatorMinusOne::NTuple{LALNumUnits,UInt16}
end

struct REAL8Sequence
  length::UInt32
  data::Ptr{Cdouble}
end

struct COMPLEX16Sequence
  length::UInt32
  data::Ptr{ComplexF64}
end

struct REAL8TimeSeries
  name::NTuple{LALNameLength,Cchar}
  epoch::LIGOTimeGPS
  δt::Cdouble
  f₀::Cdouble
  sampleUnits::LALUnit
  data::Ptr{REAL8Sequence}
end

struct COMPLEX16FrequencySeries
  name::NTuple{LALNameLength,Cchar}
  epoch::LIGOTimeGPS
  f₀::Cdouble
  δf::Cdouble
  sampleUnits::LALUnit
  data::Ptr{COMPLEX16Sequence}
end

struct LALFrDetector
  name::NTuple{LALNameLength,Cchar}
  prefix::NTuple{3,Cchar}
  vertexLongitudeRadians::Cdouble
  vertexLatitudeRadians::Cdouble
  vertexElevation::Cfloat
  xArmAltitudeRadians::Cfloat
  xArmAzimuthRadians::Cfloat
  yArmAltitudeRadians::Cfloat
  yArmAzimuthRadians::Cfloat
  xArmMidpoint::Cfloat
  yArmMidpoint::Cfloat
end

"""
Absent: No FrDetector associated with this detector
IFODiff: IFO in differential mode
IFOXArm: IFO in one-armed mode (X arm)
IFOYArm: IFO in one-armed mode (Y arm)
IFOComm: IFO in common mode
CylBar : Cylindrical bar
"""
@enum LALDetectorType::Cint begin
  Absent
  IFODiff
  IFOXArm
  IFOYArm
  IFOComm
  CylBar
end

struct LALDetector
  location::NTuple{3,Cdouble}
  detector_response::NTuple{3,NTuple{3,Cfloat}}
  type::LALDetectorType
  frDetector::LALFrDetector
end


@inline cached_detectors_ptr() = cglobal((:lalCachedDetectors, liblal), LALDetector)
