File {
  grid    = "@tdr@"
  plot    = "@tdrdat@"
  trappedcarplotfile = "n@node@_trap"
}


Electrode {
        { name="c1" voltage=@bias@}  
  { name="c2" voltage=0.0}       
}



Physics {

 EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))

  Traps(
    (@trap_type@ Gaussian fromMidBandGap
     Conc=1e17 EnergyMid=@shift@ EnergySig=0.1
     eXsection=1e-8 hXsection=1e-8)
  )
}

TrappedCarDistrPlot {
        Material="Silicon"{(0. 0.)}
}


Plot {
        Potential Electricfield
        Doping eDensity hDensity SpaceCharge
        IntrinsicDensity
        eQuasiFermi hQuasiFermi
        BandGap ConductionBand ValenceBand
      eTrappedCharge hTrappedCharge
      eGapStatesRecombination hGapStatesRecombination 
}

Math {
  TrapDLN=70
}


Solve {

  Coupled (iterations=100) { Poisson }
  coupled {poisson electron hole}
}




