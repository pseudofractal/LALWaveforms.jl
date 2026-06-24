using LALWaveforms
using Documenter

DocMeta.setdocmeta!(LALWaveforms, :DocTestSetup, :(using LALWaveforms); recursive=true)

makedocs(;
    modules=[LALWaveforms],
    authors="pseudofractal",
    sitename="LALWaveforms.jl",
    format=Documenter.HTML(;
        canonical="https://pseudofractal.github.io/LALWaveforms.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pseudofractal/LALWaveforms.jl",
    devbranch="main",
)
