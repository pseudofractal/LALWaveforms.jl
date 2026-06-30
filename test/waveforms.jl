const TD_APPROXIMANTS = [
  (TaylorT4, lalsim.TaylorT4),
  (IMRPhenomD, lalsim.IMRPhenomD),
  (SEOBNRv4, lalsim.SEOBNRv4),
  (IMRPhenomPv2, lalsim.IMRPhenomPv2),
  (IMRPhenomXAS, lalsim.IMRPhenomXAS),
]

const FD_APPROXIMANTS = [
  (IMRPhenomD, lalsim.IMRPhenomD),
  (IMRPhenomPv2, lalsim.IMRPhenomPv2),
  (IMRPhenomXAS, lalsim.IMRPhenomXAS),
]

function python_td_waveform(
  m1,
  m2,
  approximant;
  S₁x = 0.0,
  S₁y = 0.0,
  S₁z = 0.0,
  S₂x = 0.0,
  S₂y = 0.0,
  S₂z = 0.0,
)
  hp, hc = lalsim.SimInspiralChooseTDWaveform(
    m1,
    m2,
    S₁x,
    S₁y,
    S₁z,
    S₂x,
    S₂y,
    S₂z,
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
  (
    h₊ = pyconvert(Vector{Float64}, hp.data.data),
    hₓ = pyconvert(Vector{Float64}, hc.data.data),
    δt = pyconvert(Float64, hp.deltaT),
    epoch = pyconvert(Float64, hp.epoch.gpsSeconds) +
            1e-9 * pyconvert(Float64, hp.epoch.gpsNanoSeconds),
  )
end

function python_fd_waveform(
  m1,
  m2,
  approximant;
  S₁x = 0.0,
  S₁y = 0.0,
  S₁z = 0.0,
  S₂x = 0.0,
  S₂y = 0.0,
  S₂z = 0.0,
)
  hp, hc = lalsim.SimInspiralChooseFDWaveform(
    m1,
    m2,
    S₁x,
    S₁y,
    S₁z,
    S₂x,
    S₂y,
    S₂z,
    1e6 * PC_SI,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1 / 16384,
    40.0,
    0.0,
    0.0,
    lal.CreateDict(),
    approximant,
  )
  (
    h̃₊ = pyconvert(Vector{ComplexF64}, hp.data.data),
    h̃ₓ = pyconvert(Vector{ComplexF64}, hc.data.data),
    δf = pyconvert(Float64, hp.deltaF),
    epoch = pyconvert(Float64, hp.epoch.gpsSeconds) +
            1e-9 * pyconvert(Float64, hp.epoch.gpsNanoSeconds),
  )
end

function compare_td_waveform(
  jl_approximant,
  py_approximant;
  S₁x = 0.0,
  S₁y = 0.0,
  S₁z = 0.0,
  S₂x = 0.0,
  S₂y = 0.0,
  S₂z = 0.0,
)
  m1 = 30 * MSUN
  m2 = 30 * MSUN

  jl = generate_td_waveform(jl_approximant, m1, m2; S₁x, S₁y, S₁z, S₂x, S₂y, S₂z)
  py = python_td_waveform(m1, m2, py_approximant; S₁x, S₁y, S₁z, S₂x, S₂y, S₂z)

  @test jl.δt ≈ py.δt atol = 1e-15
  @test jl.epoch ≈ py.epoch atol = 1e-8

  @test length(jl.h₊) == length(py.h₊)
  @test length(jl.hₓ) == length(py.hₓ)

  @test jl.h₊ ≈ py.h₊ rtol = 1e-12 atol = 1e-15
  @test jl.hₓ ≈ py.hₓ rtol = 1e-12 atol = 1e-15
end

function compare_fd_waveform(
  jl_approximant,
  py_approximant;
  S₁x = 0.0,
  S₁y = 0.0,
  S₁z = 0.0,
  S₂x = 0.0,
  S₂y = 0.0,
  S₂z = 0.0,
)
  m1 = 30 * MSUN
  m2 = 30 * MSUN

  jl = generate_fd_waveform(jl_approximant, m1, m2; S₁x, S₁y, S₁z, S₂x, S₂y, S₂z)
  py = python_fd_waveform(m1, m2, py_approximant; S₁x, S₁y, S₁z, S₂x, S₂y, S₂z)

  @test jl.δf ≈ py.δf atol = 1e-15
  @test jl.epoch ≈ py.epoch atol = 1e-8

  @test length(jl.h̃₊) == length(py.h̃₊)
  @test length(jl.h̃ₓ) == length(py.h̃ₓ)

  @test jl.h̃₊ ≈ py.h̃₊ rtol = 1e-12 atol = 1e-15
  @test jl.h̃ₓ ≈ py.h̃ₓ rtol = 1e-12 atol = 1e-15
end

@testset "Waveforms" begin
  @testset "Time domain" begin
    @testset "Non-spinning" begin
      for (jl, py) in TD_APPROXIMANTS
        @testset "$jl" begin
          compare_td_waveform(jl, py)
        end
      end
    end

    @testset "Spinning" begin
      compare_td_waveform(IMRPhenomPv2, lalsim.IMRPhenomPv2; S₁z = 0.5, S₂z = -0.3)
    end
  end

  @testset "Frequency domain" begin
    @testset "Non-spinning" begin
      for (jl, py) in FD_APPROXIMANTS
        @testset "$jl" begin
          compare_fd_waveform(jl, py)
        end
      end
    end

    @testset "Spinning" begin
      compare_fd_waveform(IMRPhenomPv2, lalsim.IMRPhenomPv2; S₁z = 0.5, S₂z = -0.3)
    end
  end
end
