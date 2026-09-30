#setdep @node|SdeviceSBTE_init@

### Number of slices in non-local channel
#define _nSlices_ @<1+int((2*Lnl_sde+L)/zSpacing)>@

#define _Vd_      @VDRAIN@
#define _Vg1_     @VGATE@
#define _WF_      @WF@

#if "@Type@" == "nMOS"
#define _CAR_           Electron    
#define _Vg0_          -0.1
#define _Digits_        105
#define _errRefPoisson_ 1.e+100

#elif "@Type@" == "pMOS"
#define _CAR_           Hole     
#define _Vg0_           0.1
#define _Digits_        103
#define _errRefPoisson_ 1.e+100

#else
puts "Type is incorrect... @Type@"
#endif


Electrode {
    { name="gate"          voltage= _Vg0_   Workfunction= _WF_ }
    { name="source"        voltage= 0 }
    { name="drain"         voltage= _Vd_ }
    { name="substrate"     voltage= 0 }
}

File {
    grid      = "n@node|genStackedNanoslab@_fps.tdr"
    plot      = "n@node@_des.tdr"
    output    = "n@node@_des.log"
    current   = "n@node@_des.plt"
    parameter = "@parameter@"
    load      = "n@node|SdeviceSBTE_init@_Vd_des.sav"
}

Physics {
        EffectiveIntrinsicDensity( BandGapNarrowing(OldSlotboom) )
    	Mobility (PhuMob Enormal)

!(
  set BsolverCommand \
{        ExternalBoltzmannSolver "slices_n@node@%id%" (
          NumberOfSlices = _nSlices_ 
          DampingLength = 0.002
          MaxMismatch = 0.00025

        #if "@Type@"=="pMOS"
          Carriers = (hole)
          Mobility(Hole)
        #else
          Carriers= (electron)
          Mobility(Electron)
        #endif

          ContactName = "gate"
          SBTECommandFile = "pp@node@_qtx%id%.tcl"
        ) }

  for {set i 0} {$i < @nStack@} {incr i} {
    set id "_${i}"
    puts [string map [list %id% $id] $BsolverCommand]
    puts " "
  }
)!

}

Plot {
  eDensity hDensity eCurrent/Vector hCurrent/Vector TotalCurrent/Vector
  Potential Electricfield/Vector Doping SpaceCharge
  eMobility hMobility eVelocity/Vector hVelocity/Vector
  BandGap Affinity BandGapNarrowing EffectiveBandGap EffectiveIntrinsicDensity
  ConductionBand ValenceBand
  eQuasiFermi hQuasiFermi eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eQuantumPotential hQuantumPotential
  eQMBandgapShift hQMBandgapShift
  LayerThickness NearestInterfaceOrientation

  ##xMoleFraction
  ##eBand2BandGeneration hBand2BandGeneration Band2BandGeneration
}

Math {
    #-PlotLoadable PlotExplicit
    ##ExitOnFailure
    RelErrControl
    ######################################################
    ### Consider potential convergence criteria, 
    ### carrier convergence is controlled indirectly by potential 
    ErrRef(Poisson)=_errRefPoisson_
    ErrRef(Electron)=1.e+200
    ErrRef(Hole)=1.e+200
    RhsMin= 1.0e-100
    RhsMax= 1.0e+100
    RhsFactor= 1.0e+100
    ##Digits = 104
    Digits = _Digits_
    Iterations= 15
    NumberOfThreads= @Threads@
    ##################################################
    ### Make the simulation continue to the next bias, 
    ### even if the convergence criteria are not met.
    AcceptNewtonParameter (
        -RhsAndUpdateConvergence * enable 'RHS OR Update' convergence
        RhsMin = 1.e10 * RHS converged if 'RHS < RhsMin'
        UpdateScale = 1e10 * scale actual update error
    )

    CurrentWeighting
}

Solve {
    Coupled(Iterations=25 LineSearchDamping=1e-3) { Poisson }
    Coupled(Iterations=25 LineSearchDamping=1) { Poisson _CAR_ }

    NewCurrentFile="IdVg_"
    ##########################################################
    ### Simulate only the bias points, divided by 'Intervals'
    ### the bias between 'Intervals' not allowed.
    Quasistationary(
    	InitialStep= 1 Increment= 1
        MaxStep= 1 MinStep= 1
        Goal { Name="gate" Voltage= _Vg1_ }

        	AcceptNewtonParameter ( ReferenceStep = 1 )

    ){  Coupled{Poisson _CAR_}  
        CurrentPlot (Time= (range=(0 1) intervals=8) )
    }    
}






