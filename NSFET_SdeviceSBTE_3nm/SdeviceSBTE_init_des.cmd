#setdep @node|genStackedNanoslab@

#define _IdVg_    0
#define _Vd_      @VDRAIN@
#define _Vg1_     @VGATE@
#define _WF_      @WF@

#if "@Type@" == "nMOS"
#define _CAR_     Electron    
#define _Vg0_     -0.1

#elif "@Type@" == "pMOS"
#define _CAR_     Hole     
#define _Vg0_      0.1

#else
puts "Type is incorrect... @Type@"
#endif


Electrode {
    { name="gate"          voltage= _Vg0_  Workfunction= _WF_ }
    { name="source"        voltage= 0 }
    { name="drain"         voltage= 0 }
    { name="substrate"     voltage= 0 }
}

File {
    grid      = "n@node|genStackedNanoslab@_fps.tdr"
    plot      = "n@node@_des.tdr"
    output    = "n@node@_des.log"
    current   = "n@node@_des.plt"
    parameter = "@parameter@"
}

Physics {
        EffectiveIntrinsicDensity( BandGapNarrowing(OldSlotboom) )
    	Mobility (PhuMob Enormal)
}

Plot {
  eDensity hDensity eCurrent/Vector hCurrent/Vector TotalCurrent/Vector
  Potential Electricfield/Vector Doping SpaceCharge
  eMobility hMobility eVelocity/Vector hVelocity/Vector
  BandGap Affinity BandGapNarrowing EffectiveBandGap EffectiveIntrinsicDensity
  ConductionBand ValenceBand
  eQuasiFermi hQuasiFermi eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eQuantumPotential hQuantumPotential
  LayerThickness NearestInterfaceOrientation

  ##xMoleFraction
  ##eBand2BandGeneration hBand2BandGeneration Band2BandGeneration
}

Math {
  CoordinateSystem { UCS }
  -CheckUndefinedModels
  AutoOrientationSmoothingDistance = -1
  GeometricDistances

  Extrapolate
  Derivative
  Method=ILS
  RhsMin = 1e-12
  Iterations=20

  ILSrc =
  "set(1){
    iterative(gmres(1000), tolrel=1e-10, tolunprec=1e-8, tolabs=0, maxit=200);
    preconditioning(ilut(0.001,-1),left);
    ordering ( symmetric=nd, nonsymmetric=mpsilst );
    options( compact=yes, linscale=0, refineresidual=8, verbose=0); };  "

  wallclock
  ExitOnFailure

  Number_of_Threads = @Threads@

  CurrentPlot( IntegrationUnit=cm )
  CurrentWeighting
}


Solve {
  Coupled(Iterations=100 LineSearchDamping=1e-3) { Poisson }
  Coupled(Iterations=100 LineSearchDamping=1e-3) { Poisson _CAR_ }

  Quasistationary(
    InitialStep= 1 Increment= 1
    MaxStep= 1 MinStep= 1
    Goal { Name="drain" Voltage= _Vd_ }
  ){ Coupled(Iterations=50 LineSearchDamping=1) { Poisson _CAR_ } 
##      CurrentPlot (Time= (range=(0 1) intervals=14) )
  }
  Save ( FilePrefix= "n@node@_Vd" ) 

#if _IdVg_

  NewCurrentFile="IdVg_"
  Quasistationary (
    DoZero
    InitialStep=1e-2 Increment=1.5
    MinStep=1e-6 MaxStep=0.05
    Goal { Name="gate" Voltage= _Vg1_  }
  ){ Coupled { Poisson _CAR_ }
*    CurrentPlot( Time=(Range=(0 1) Intervals=20) )
  }

#endif
}


