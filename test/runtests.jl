include("common.jl")

@testset "LALWaveforms.jl" begin
  include("waveforms.jl")
  include("detectors.jl")
  include("pipeline.jl")
end
