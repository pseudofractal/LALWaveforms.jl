"""
    Approximant

Enumeration of the waveform approximants implemented in LALSimulation that can be used with
[`generate_td_waveform`](@ref) and [`generate_fd_waveform`](@ref). Each member corresponds to the identically‑named entry in the
C `Approximant` enum defined in
[`LALSimInspiral.h`](https://lscsoft.docs.ligo.org/lalsuite/7.26/lalsimulation/group___l_a_l_sim_inspiral__h.html).

Only approximants that are actually implemented in LALSimulation are included;
historical placeholders (e.g. `BCV`, `FrameFile`) and models marked *“Not implemented”*
in the official documentation have been omitted.

# External documentation

The complete list of approximants and their descriptions can be found in the
[LALSimulation inspiral group](https://lscsoft.docs.ligo.org/lalsuite/7.26/lalsimulation/group___l_a_l_sim_inspiral__h.html#gab955e4603c588fe19b39e47870a7b69c)
of the LALSuite Doxygen pages.
"""
@enum Approximant::Cint begin
  TaylorT1 = 0
  TaylorT2 = 1
  TaylorT3 = 2
  EccentricFD = 4
  TaylorF2 = 5
  TaylorF2Ecc = 6
  TaylorF2NLTides = 7
  TaylorF2RedSpin = 9
  TaylorF2RedSpinTidal = 10
  SpinTaylorT1 = 16
  SpinTaylorT4 = 19
  SpinTaylorT5 = 20
  SpinTaylorF2 = 21
  PhenSpinTaylor = 24
  PhenSpinTaylorRD = 25
  EOBNRv2 = 37
  EOBNRv2HM = 38
  TEOBResum_ROM = 41
  SEOBNRv1 = 42
  SEOBNRv2 = 43
  SEOBNRv2_opt = 44
  SEOBNRv3 = 45
  SEOBNRv3_pert = 46
  SEOBNRv3_opt = 47
  SEOBNRv3_opt_rk4 = 48
  SEOBNRv4 = 49
  SEOBNRv4_opt = 50
  SEOBNRv4P = 51
  SEOBNRv4PHM = 52
  SEOBNRv2T = 53
  SEOBNRv4T = 54
  SEOBNRv1_ROM_EffectiveSpin = 55
  SEOBNRv1_ROM_DoubleSpin = 56
  SEOBNRv2_ROM_EffectiveSpin = 57
  SEOBNRv2_ROM_DoubleSpin = 58
  SEOBNRv2_ROM_DoubleSpin_HI = 59
  Lackey_Tidal_2013_SEOBNRv2_ROM = 60
  SEOBNRv4_ROM = 61
  SEOBNRv4HM_ROM = 62
  SEOBNRv4_ROM_NRTidal = 63
  SEOBNRv4_ROM_NRTidalv2 = 64
  SEOBNRv4_ROM_NRTidalv2_NSBH = 65
  SEOBNRv4T_surrogate = 66
  HGimri = 67
  IMRPhenomA = 68
  IMRPhenomB = 69
  IMRPhenomC = 72
  IMRPhenomD = 73
  IMRPhenomD_NRTidal = 74
  IMRPhenomD_NRTidalv2 = 75
  IMRPhenomNSBH = 76
  IMRPhenomHM = 77
  IMRPhenomP = 78
  IMRPhenomPv2 = 79
  IMRPhenomPv2_NRTidal = 80
  IMRPhenomPv2_NRTidalv2 = 81
  TaylorEt = 83
  TaylorT4 = 84
  EccentricTD = 85
  SpinTaylorT4Fourier = 87
  SpinTaylorT5Fourier = 88
  SpinDominatedWf = 89
  NR_hdf5 = 90
  NRSur4d2s = 91
  NRSur7dq2 = 92
  NRSur7dq4 = 93
  SEOBNRv4HM = 94
  NRHybSur3dq8 = 95
  IMRPhenomXAS = 96
  IMRPhenomXHM = 97
  IMRPhenomPv3 = 98
  IMRPhenomPv3HM = 99
  IMRPhenomXP = 100
  IMRPhenomXPHM = 101
  TEOBResumS = 102
  IMRPhenomT = 103
  IMRPhenomTHM = 104
  IMRPhenomTP = 105
  IMRPhenomTPHM = 106
  SEOBNRv5_ROM = 107
  SEOBNRv4HM_PA = 108
  pSEOBNRv4HM_PA = 109
  IMRPhenomXAS_NRTidalv2 = 110
  IMRPhenomXP_NRTidalv2 = 111
  IMRPhenomXO4a = 112
  SEOBNRv5HM_ROM = 114
  IMRPhenomXAS_NRTidalv3 = 115
  IMRPhenomXP_NRTidalv3 = 116
  SEOBNRv5_ROM_NRTidalv3 = 117
  IMRPhenomXPNR = 118
end
