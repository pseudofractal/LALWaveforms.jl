const TEST_DETECTORS = (LHO_4K, LLO_4K, VIRGO, KAGRA)

function python_detector(det::CachedDetector)
  py = lal.CachedDetectors[Int(det)]
  (
    py = py,
    jl = Detector(
      name = str(py.frDetector.name),
      prefix = str(py.frDetector.prefix),
      latitude = f64(py.frDetector.vertexLatitudeRadians),
      longitude = f64(py.frDetector.vertexLongitudeRadians),
      elevation = f64(py.frDetector.vertexElevation),
      xarm = Arm(
        f64(py.frDetector.xArmAltitudeRadians),
        f64(py.frDetector.xArmAzimuthRadians),
        f64(py.frDetector.xArmMidpoint),
      ),
      yarm = Arm(
        f64(py.frDetector.yArmAltitudeRadians),
        f64(py.frDetector.yArmAzimuthRadians),
        f64(py.frDetector.yArmMidpoint),
      ),
      type = DetectorType(pyconvert(Int, py.type)),
    ),
  )
end

@testset "Detectors" begin

  @testset "Construction" begin
    for det in TEST_DETECTORS
      @testset "$det" begin
        (; py, jl) = python_detector(det)

        @test jl.name == str(py.frDetector.name)
        @test jl.prefix == str(py.frDetector.prefix)

        @test jl.latitude ≈ f64(py.frDetector.vertexLatitudeRadians)
        @test jl.longitude ≈ f64(py.frDetector.vertexLongitudeRadians)
        @test jl.elevation ≈ f64(py.frDetector.vertexElevation)

        @test jl.type == DetectorType(pyconvert(Int, py.type))
      end
    end
  end

  @testset "Location" begin
    for det in TEST_DETECTORS
      @testset "$det" begin
        (; py, jl) = python_detector(det)

        @test jl.location[1] ≈ f64(py.location[0])
        @test jl.location[2] ≈ f64(py.location[1])
        @test jl.location[3] ≈ f64(py.location[2])
      end
    end
  end

  @testset "Response tensor" begin
    for det in TEST_DETECTORS
      @testset "$det" begin
        (; py, jl) = python_detector(det)

        Rjl = convert(Matrix{Float64}, jl.response)
        Rpy = pyconvert(Matrix{Float64}, py.response)

        # LAL computes the detector response in REAL8 but stores it as
        # REAL4. Julia computes and stores it as Float64.
        @test Rjl ≈ Rpy atol = 1e-6
      end
    end
  end

  @testset "Cached detectors" begin
    for det in TEST_DETECTORS
      @testset "$det" begin
        (; jl) = python_detector(det)
        cached = Detector(det)

        @test cached.name == jl.name
        @test cached.prefix == jl.prefix

        @test cached.latitude ≈ jl.latitude
        @test cached.longitude ≈ jl.longitude
        @test cached.elevation ≈ jl.elevation

        # C version calculates using REAL8 but stores using REAL4
        # Julia version calculates and stores using Float64.
        # So we need a looser tolerance here.
        @test collect(cached.location) ≈ collect(jl.location) atol=2e-3 # 1 mm

        # Detector Response is being tested in the "Response tensor"
        # testset above, so we don't need to test it here.

        @test cached.xarm == jl.xarm
        @test cached.yarm == jl.yarm
        @test cached.type == jl.type
      end
    end
  end

  @testset "Detector type conversions" begin
    for det in TEST_DETECTORS
      py = lal.CachedDetectors[Int(det)]
      t = DetectorType(pyconvert(Int, py.type))
      @test LALDetectorType(t) == typeof(LALDetectorType(t))(pyconvert(Int, py.type))
    end
  end

  @testset "Greenwich sidereal time" begin
    times = (GPSTime(0), GPSTime(1_000_000_000), GPSTime(1_400_000_000))
    for t in times
      py_time = lal.LIGOTimeGPS(t.s, t.ns)
      @test greenwich_sidereal_time(t) ≈ pyconvert(Float64, lal.GreenwichMeanSiderealTime(py_time)) atol =
        1e-15
    end
  end

  @testset "Source direction" begin
    t = GPSTime(1_400_000_000)
    for α in (0.0, 0.4, 1.2, 2.5)
      for δ in (-0.8, -0.2, 0.0, 0.7)
        nx, ny, nz = source_direction(α, δ, t)
        @test nx^2 + ny^2 + nz^2 ≈ 1 atol = 1e-15
        gha = greenwich_sidereal_time(t) - α
        @test nx ≈ cos(δ) * cos(gha) atol = 1e-15
        @test ny ≈ -cos(δ) * sin(gha) atol = 1e-15
        @test nz ≈ sin(δ) atol = 1e-15
      end
    end
  end

end
