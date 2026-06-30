function python_pipeline(m1, m2, approximant; α = 1.2, δ = -0.4, ψ = 0.3)
  hp, hc = lalsim.SimInspiralChooseTDWaveform(
    m1,
    m2,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1e6 * PC_SI,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1 / 16384,
    40.0,
    0.0,
    lal.CreateDict(),
    approximant,
  )
  detector = lal.CachedDetectors[Int(LHO_4K)]
  gmst = lal.GreenwichMeanSiderealTime(hp.epoch)
  fp, fc = lal.ComputeDetAMResponse(detector.response, α, δ, ψ, gmst)
  h₊ = pyconvert(Vector{Float64}, hp.data.data)
  hₓ = pyconvert(Vector{Float64}, hc.data.data)
  return (
    waveform = GWTimeSeries(
      h₊,
      hₓ,
      pyconvert(Float64, hp.deltaT),
      GPSTime(pyconvert(Int32, hp.epoch.gpsSeconds), pyconvert(Int32, hp.epoch.gpsNanoSeconds)),
    ),
    fp = pyconvert(Float64, fp),
    fc = pyconvert(Float64, fc),
    strain = pyconvert(Float64, fp) .* h₊ .+ pyconvert(Float64, fc) .* hₓ,
  )
end

@testset "Pipeline" begin
  MSUN = pyconvert(Float64, lal.MSUN_SI)
  m1 = 30 * MSUN
  m2 = 30 * MSUN
  α = 1.2
  δ = -0.4
  ψ = 0.3
  py = python_pipeline(m1, m2, lalsim.IMRPhenomD; α, δ, ψ)
  jl = generate_td_waveform(
    IMRPhenomD,
    m1,
    m2;
    distance = 1e6 * PC_SI,
    inclination = 0.0,
    ϕref = 0.0,
    longAscNodes = 0.0,
    eccentricity = 0.0,
    meanPerAno = 0.0,
    δt = 1 / 16384,
    f_min = 40.0,
    f_ref = 0.0,
  )

  @test jl.δt ≈ py.waveform.δt atol = 1e-15
  @test jl.epoch == py.waveform.epoch

  @test jl.h₊ ≈ py.waveform.h₊ rtol = 1e-12 atol = 1e-15
  @test jl.hₓ ≈ py.waveform.hₓ rtol = 1e-12 atol = 1e-15

  detector = Detector(LHO_4K)

  fp, fc = antenna_response(detector, α, δ, ψ, greenwich_sidereal_time(jl.epoch))

  @test fp ≈ py.fp atol = 1e-15
  @test fc ≈ py.fc atol = 1e-15

  projected = project(detector, jl, α, δ, ψ)

  @test projected.h ≈ py.strain rtol = 1e-12 atol = 1e-15

  # Ensure the projection matches the antenna response.
  @test projected.h ≈ fp .* jl.h₊ .+ fc .* jl.hₓ atol = 1e-15

  @test projected.δt == jl.δt
  @test projected.epoch == jl.epoch
  @test projected.detector == detector

end
