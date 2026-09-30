#setdep @previous@

*--------------------------------------------------
File {
  *-Input
  Grid        = "@tdr@"
  Parameters  ="@parameter@"
  PMIPath     = "@pwd@"
  *-Output
  Plot        = "@tdrdat@"
  Current     = "@plot@"
  Output      = "@log@"
}

*--------------------------------------------------
Electrode {
  { name="cathode" voltage=0.0 }
  { name="anode" voltage=0.0 }
}

*--------------------------------------------------
Plot {
  DopingConcentration
  ConductionBandEnergy ValenceBandEnergy
  eQuasiFermiEnergy hQuasiFermiEnergy BandGap  ElectronAffinity
  eCurrent/Vector hCurrent/Vector current/vector
  SpaceCharge eDensity hDensity
  Potential
  SRH
  Auger
  SurfaceRecombination
  PMIRecombination
  Avalanche
  eMobility hMobility
}

*--------------------------------------------------
CurrentPlot{
  Auger(Integrate(Semiconductor))
  PMIRecombination(Integrate(Semiconductor))
}
*--------------------------------------------------
Physics {
  Recombination (
    SRH(DopingDep)
    # both Auger and pmi_recomb should produce the same results
    #if "@Auger@" == "builtin"
    Auger
    #elif "@Auger@" == "pmi"
    #if [string is double "@C@"]
    pmi_recomb(C = @C@)
    #else      
    pmi_recomb
    #endif
    #endif
  )
  Mobility(
    DopingDep
  )
  EffectiveIntrinsicDensity(
    BandGapNarrowing (delAlamo)
  )
} * end physics

*--------------------------------------------------
Math {
  -ExtendedPrecision
  Extrapolate
  Digits=5
  ErrRef(electron) = 1e5
  ErrRef(hole)     = 1e5
  Iterations = 10
  CurrentPlot(IntegrationUnit=cm)
}

*--------------------------------------------------
Solve {
  NewCurrentPrefix = "tmp_"
  Poisson
  Coupled (Iterations=100) { poisson electron hole  }
  
  NewCurrentPrefix = "" 
  Quasistationary ( 
    InitialStep=5e-5 MaxStep =5e-2 MinStep = 1e-5
    Goal{ voltage = 0.5 Name="anode" }
  ){ Coupled {Poisson Electron Hole  } } 
  System("rm -f tmp*@node@*")
}
