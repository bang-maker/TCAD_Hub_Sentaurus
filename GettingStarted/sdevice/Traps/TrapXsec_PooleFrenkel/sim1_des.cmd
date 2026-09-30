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

#default paramater values
##########################
#define 	_ActivatePF_e_ 1
#define 	_ActivatePF_h_ 1
#define 	_epsPF_e_ 11.7
#define 	_epsPF_h_ 11.7
#define 	_a_power_e_ 1
#define 	_a_power_h_ 1

#define 	_ActivatePhonon_e_ 0
#define 	_ActivatePhonon_h_ 0
#define 	_b_power_e_ 1
#define 	_b_power_h_ 1
#define 	_ph_mass_e_ 0.25
#define 	_ph_mass_h_ 0.4
#define 	_ph_tau1_e_ 5e-15
#define 	_ph_tau1_h_ 5e-15


##########################
#if @ActivatePF@
   #define 	_ActivatePF_e_ 1
   #define 	_ActivatePF_h_ 1
#else
   #define 	_ActivatePF_e_ 0
   #define 	_ActivatePF_h_ 0
#endif

#if @ActivatePhonon@
   #define 	_ActivatePhonon_e_ 1
   #define 	_ActivatePhonon_h_ 1
#endif

#if "@par@" == "a_power"
   #define 	_a_power_e_ @par_val@
   #define 	_a_power_h_ @par_val@
#elif "@par@" == "epsPF"
   #define 	_epsPF_e_ @par_val@
   #define 	_epsPF_h_ @par_val@
#endif


File {
  grid    = "@tdr@"
  plot    = "@tdrdat@"
  parameter = "@parameter@"
  current = "@plot@"
}


Electrode {
        { name="c1" voltage=0.0 Resist=_resist_ }
  { name="c2" voltage=0.0 }       
}

Physics {
  Mobility (DopingDep HighFieldSat)
  EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
  Traps(
    (eNeutral Level fromMidBandGap
     Conc=1e15 EnergyMid=@shift@ EnergySig=0.01
     eXsection=@Xsec@ hXsection=@Xsec@
      #if "@Xsec_model@" == "PooleFrenkel"
      PooleFrenkel
      #endif
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
