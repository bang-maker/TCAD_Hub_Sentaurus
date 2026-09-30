File {
  grid    = "@tdr@"
}

Electrode {
        { name="c1" voltage=0.0}  
  { name="c2" voltage=0.0}       
}

Physics {
#if "@trap_type@" != "none"
  Traps(
    (@trap_type@ Gaussian fromMidBandGap
     Conc=1e17 EnergyMid=0. EnergySig=0.1
     eXsection=1e-8 hXsection=1e-8)
  )
#endif  
}

Plot {
        Potential Electricfield
        Doping eDensity hDensity SpaceCharge
        eQuasiFermi hQuasiFermi
      eTrappedCharge hTrappedCharge
      eGapStatesRecombination hGapStatesRecombination 
}

Solve {

  Set(TrapFilling=@fill_control@)
  Poisson
  Plot(FilePrefix="n@node@_@fill_control@")
}




