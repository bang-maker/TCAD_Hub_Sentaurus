File {
  grid    = "@tdr@"
  plot    = "@tdrdat@"
   trappedcarplotfile = "n@node@_trap"
}

Electrode {
        { name="c1" voltage=0.0}  
  { name="c2" voltage=0.0}       
}

Physics {

#if "@DOS@" == "table"
  Traps(
    (@trap_type@ 
     Table=(0.45 1e12
            0.46 @conc@
            0.48 @conc@
            0.49 1e12)
     fromCondBand
     eXsection=@Xsec@ hXsection=@Xsec@)
  )
#else
  Traps(
    (@trap_type@ @DOS@ fromMidBandGap
     Conc=@conc@ EnergyMid=@shift@ EnergySig=@Esig@
     eXsection=@Xsec@ hXsection=@Xsec@)
  )
#endif
  
}

TrappedCarDistrPlot {
        Material="Silicon"{(0. 0.)}
}

Plot {
        Potential Electricfield
        Doping eDensity hDensity SpaceCharge
        eQuasiFermi hQuasiFermi
        BandGap ConductionBand ValenceBand
#if "@trap_type@" != "none"
      eTrappedCharge hTrappedCharge
      eGapStatesRecombination hGapStatesRecombination 
#endif
}

Math {
  TrapDLN=50  
}


Solve {

  Poisson
  coupled {poisson electron hole}
}




