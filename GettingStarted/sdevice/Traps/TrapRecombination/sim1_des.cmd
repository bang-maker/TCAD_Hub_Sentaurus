#if "@regime@" == "forward"
#define _resist_ 0.01
#define _Vend_ 5.0
#define _out_ "n@node@_fwd"
#else
#define _resist_ 1.e10
#define _Vend_ -100.0
#define _out_ "n@node@_rev"
#endif

#define _tend_ 1.

File {
  grid    = "@tdr@"
  plot    = "@tdrdat@"
  current = "n@node@"
}


Electrode {
        { name="c1" voltage=0.0 Resist=_resist_ }
  { name="c2" voltage=0.0 }       
}



Physics {
  Mobility (DopingDep HighFieldSat)
  EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
  Traps(
    (eNeutral Gaussian fromMidBandGap
     Conc=1e15 EnergyMid=@shift@ EnergySig=0.01
     eXsection=@Xsec@ hXsection=@Xsec@
    )
  )
  
}

Plot {
        Potential Electricfield
        Doping eDensity hDensity SpaceCharge IntrinsicDensity
        eCurrentDensity/vector hCurrentDensity/vector TotalCurrentDensity/vector 
        eQuasiFermi hQuasiFermi
        BandGap EffectiveBandGap ConductionBand ValenceBand
      eTrappedCharge hTrappedCharge
      eGapStatesRecombination hGapStatesRecombination 
      TrappingRates
}

Math {
  AvalDerivatives
  ErrRef(electron)=1e-2
  ErrRef(hole)=1e-2
  extrapolate
  derivatives
  TrapDLN=50  
  method=pardiso
  iterations=20
}


Solve {

  Poisson
  coupled {poisson electron hole}
  
  

  Quasistationary (
    InitialStep=0.05 Minstep=1e-5 MaxStep=0.01 increment=1.41
    Goal {name="c1" voltage=_Vend_}
  ) { coupled { poisson electron hole } }
}
