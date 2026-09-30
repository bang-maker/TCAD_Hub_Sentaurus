*----------------------------------------
* $Id: //tcad/support/main/examples/opto/solarcell/si/simple/sc-iv-light/sdevice_des.cmd#11 $
* Author: Gergoe Letay
*- Purpose: Simulate electrics/optics for light IV 
#setdep @previous@

*--------------------------------------------------
File {
  *-Input
  Grid                 = "@tdr@"
  IlluminationSpectrum = "@pwd@/am15g.txt"
  *-Output
  Plot                 = "@tdrdat@"
  SpectralPlot         = "n@node@_spec"
  Current              = "@plot@"
  Output               = "@log@"
  OpticsOutput = "n@node@_optics"
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
  eMobility hMobility
  SRH Auger TotalRecombination SurfaceRecombination
  eLifeTime hLifeTime  
  EffectiveIntrinsicDensity IntrinsicDensity
  OpticalIntensity
  OpticalGeneration
  ComplexRefractiveIndex
}

*--------------------------------------------------
CurrentPlot{
  OpticalGeneration(Integrate(Semiconductor) ) 
  AbsorbedPhotonDensity(Integrate(Everywhere) ) 
  SRH(Integrate(Semiconductor))
  Auger(Integrate(Semiconductor))
}

*--------------------------------------------------
Physics {
  Area = !(puts -nonewline [expr 1.e11/$wtot])! * to get current in mA/cm^2
  Recombination(
    SRH
    Auger
  )
  Mobility(
    DopingDep
  )
  EffectiveIntrinsicDensity(
    BandGapNarrowing (delAlamo)
  )
  Optics (
    ComplexRefractiveIndex (WavelengthDep(Real Imag))
    OpticalGeneration (
      QuantumYield(StepFunction(EffectiveBandgap)) * generated carriers/photon, default: 1
      ComputeFromSpectrum(
        Select(
          Parameter=("Wavelength")
          Condition="$Wavelength <= 1.2"
        )
        keepSpectralData
      ) * end ComputeFromSpectrum
    ) * end OpticalGeneration
    Excitation (
      fromTop
      Window ( 
        * origin is not required, as fromTop automatically shifts the 
        * illumination window to the top of the structure.
        # Origin = (0,-0.075)  
        Line(x1=!(puts -nonewline $wfront)! x2=!(puts -nonewline $wtot)!)
        * improve accuracy due to mismatch of illumination window width & grid.
        WeightedAPDIntegration(
          * to increase accuracy, for layers thicker 100um, set > 1e4 ... 1e5
          # NumberOfCellsPerLayer = 50000 
        ) 
      ) * end Window
    ) * end Excitation
    OpticalSolver (
      TMM (
        LayerStackExtraction ()
        IntensityPattern = Envelope
      ) *end TMM
    )	* end OpticalSolver
  ) * end Optics
} * end physics

Physics (regionInterface="frontArc/substrate") {
  Recombination(surfaceSRH)
} 

*--------------------------------------------------
Math{
  Extrapolate 
  Derivatives   
  RelErrControl 
  Digits=5              
  Iterations=8  
  Notdamped=100 
  SubMethod=ParDiSo
  Method=Blocked
  ExitOnFailure
  BreakCriteria {
    Current (Contact = "cathode" minval = -1e-3)
  }
}

*--------------------------------------------------
Solve{
  NewCurrentPrefix = "tmp_"
  Poisson
  NewCurrentPrefix = "" 
  Coupled (Iterations=100) { poisson electron hole  }
  
  * fast voltage controlled ramping until mpp
  Quasistationary ( 
    InitialStep=2e-1 MaxStep =2e-1 MinStep = 1e-5
    Goal{ voltage = 0.45 Name="anode" }
  ){ Coupled {Poisson Electron Hole  } } 
  * voltage controlled ramping for better resolution at mpp
  Quasistationary ( 
    InitialStep=4e-2 MaxStep =4e-2 MinStep = 1e-5
    Goal{ voltage = 0.8 Name="anode" }
  ){ Coupled {Poisson Electron Hole  } }
  System("rm -f tmp*") *remove the plot we dont need anymore.              
}
