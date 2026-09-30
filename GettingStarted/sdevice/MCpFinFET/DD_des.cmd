#setdep @previous@ 


Electrode {
  { Name="Source" Voltage= 0.0 }
  { Name="Drain"  Voltage= 0.0 }
  { Name="Gate"   Voltage= 0.0 Workfunction=@Work@ }
}

File {
  Grid=     "@tdr@"
  Current=  "@plot@" 
  Save=     "@save@"
  Output=   "@log@"
  Plot=     "@tdrdat@"
  Parameter="@parameter@"
}

Physics { AreaFactor=1 }
  
Physics(Material=Silicon) {
  Mobility( PhuMob HighFieldSaturation Enormal )
  EffectiveIntrinsicDensity ( Slotboom NoFermi )
}

Math {
  Number_of_Threads = 1
  Method=blocked
  Submethod=pardiso
  Extrapolate
  RelErrControl
  Digits=6
  ErrRef(Electron)=1.e8
  ErrRef(Hole)=1.e8
  NotDamped=11
  Iterations=10
  ExitOnFailure
}

Solve {
  Coupled(Iterations=100 LineSearchDamping = 1e-4){ Poisson } 
  Coupled { Poisson Hole }

  Quasistationary ( 
    Goal { Name=Drain Voltage=@V_SUPPLY@ }
    Initialstep=0.01 Maxstep=0.2 Minstep=1e-8 Increment=1.4
  ){ Coupled { Poisson Hole } } 

  NewCurrentFile="IdVg_"
  Quasistationary ( 
    Goal { Name=Gate Voltage=@V_SUPPLY@ }
    Initialstep=0.01 Maxstep=0.01 Minstep=1e-8 Increment=1.4 DoZero
  ){ Coupled { Poisson Hole } } 
}

Plot { 
  Potential 
  ValenceBandEnergy
  ElectricField/Vector
  hVelocity/Vector
  hdensity
  hCurrent/Vector
} 

