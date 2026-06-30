using LALWaveforms
using Documenter

DocMeta.setdocmeta!(LALWaveforms, :DocTestSetup, :(using LALWaveforms); recursive = true)

makedocs(
  modules = [LALWaveforms],
  authors = "pseudofractal",
  sitename = "LALWaveforms.jl",
  checkdocs = :exports,
  format = Documenter.HTML(
    canonical = "https://pseudofractal.github.io/LALWaveforms.jl",
    edit_link = "main",
  ),
  pages = ["Home" => "index.md"],
)

deploydocs(repo = "github.com/pseudofractal/LALWaveforms.jl.git", devbranch = "main")
