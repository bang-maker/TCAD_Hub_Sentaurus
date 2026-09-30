#setdep @previous@

File {
  * input files:
  Grid=   "@tdr@"
  PMIPath= "@pwd@"
  * output files:
  Plot=   "@tdrdat@"
  Current="@plot@"
  Output= "@log@"
}

Electrode {
  { Name="source"    Voltage= 0.0 }
  { Name="drain"     Voltage= 0.0 }
  { Name="gate"      Voltage= 0.0 }
  { Name="substrate" Voltage= 0.0 }
}

Physics{
  EffectiveIntrinsicDensity( OldSlotboom )     
}

Physics(Material="Silicon"){
  Mobility (
    # pmis should produce the same results
    #if "@pmi@" == "pmi"
    DopingDep (pmi_dopingdep)
    Enormal (pmi_enormal)
    HighFieldSaturation (pmi_highfield GradQuasiFermi)
    #elif "@pmi@" == "pmi_std"
    DopingDep (pmi_dopingdep_std)
    Enormal (pmi_enormal_std)
    HighFieldSaturation (pmi_highfield_std GradQuasiFermi)
    #else
    DopingDep (Masetti)
    Enormal (Lombardi)
    HighFieldSaturation (CaugheyThomas GradQuasiFermi)
    #endif
  )
  Recombination(
    SRH( DopingDependence )
  )           
}

Math { 
  Extrapolate
  Iterations= 20
  ExitOnFailure
}


Solve {
  *- Creating initial guess:
  Coupled(Iterations= 100){ Poisson } 
  Coupled {Poisson Electron Hole}
  
  *- Ramp drain to VdLin
  Quasistationary( 
    InitialStep= 0.1 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 1 
    Goal { Name="drain" Voltage=@VdLin@ } 
  ){ Coupled {Poisson Electron Hole} } 
  
  *- Vg sweep 
  NewCurrentPrefix="IdVgLin_" 
  Quasistationary( 
    DoZero 
    InitialStep= 0.01 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 0.05 
    Goal { Name="gate" Voltage= 3.0 } 
  ){ Coupled {Poisson Electron Hole} }
  
  *- Ramp drain to zero
  NewCurrentPrefix=""
  Quasistationary( 
    InitialStep= 0.1 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 1 
    Goal { Name="drain" Voltage= 0.0 } 
  ){ Coupled {Poisson Electron Hole} }
  
  NewCurrentPrefix="IdVd_"
  Quasistationary( 
    DoZero
    InitialStep= 0.01 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 0.05 
    Goal { Name="drain" Voltage= @VdSat@ } 
  ){ Coupled {Poisson Electron Hole} }   
  
}

