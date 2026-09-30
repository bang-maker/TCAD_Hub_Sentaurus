#setdep @previous@

*--------------------------------------------------
File {
  Output  = "@log@"
}
*--------------------------------------------------

Device "diode" {
  File {
    *-Input
    Grid    = "@tdr@"
    *-Output
    Plot    = "@tdrdat@"
    Current = "@plot@"
  }
  
  *--------------------------------------------------
  Electrode {   
    { Name="cathode" Voltage=0.0 }
    { Name="anode"   Voltage=0.0 }
  }
  
  *--------------------------------------------------
  Plot {
    SRH Auger
    AbsorbedPhotonDensity
    OpticalGeneration
    QuantumYield
    ComplexRefractiveIndex
  }
  
  *--------------------------------------------------
  CurrentPlot{
    OpticalGeneration(Integrate(Semiconductor) ) 
    AbsorbedPhotonDensity(Integrate(Semiconductor) ) 
  }
  
  *--------------------------------------------------
  Physics {
    Recombination( SRH(DopingDependence) Auger )
    Mobility( DopingDep )
    Optics (
      ComplexRefractiveIndex (
        WavelengthDep(Real Imag)
      )
      OpticalGeneration (
        QuantumYield(StepFunction(EffectiveBandgap))
        ComputeFromMonochromaticSource(
        )
      )
      Excitation (
        Wavelength = @lambda@   # [um]
        Intensity  = 0.1  # [W/cm^2]
        Window ( 
          Origin = (2.5,0)
          Line(dx=3)
        )
      )
      OpticalSolver (
        TMM (
          LayerStackExtraction()
        ) 
      )
    )
  }
}

System {
  diode "d" ("anode"=np "cathode"=nn)
  Vsource_pset "vp" (np gnd) {dc=0} 
  Vsource_pset "vn" (nn gnd) {dc=0} 
  Set (gnd = 0.0)
  plot "n@node@_sys" ( 
    v(nn) v(np) i(d nn) i(d np)
  )
}

*--------------------------------------------------
Solve{
  NewCurrentPrefix="tmp_"
  
  Poisson
  Coupled {Poisson Circuit}
  Coupled {Poisson Electron Hole Circuit}
  
  NewCurrentPrefix=""
  
  Quasistationary (
    DoZero
    InitialStep = 0.1   
    MaxStep     = 0.5   
    MinStep     = 1e-3
    Goal { Parameter ="vn".dc Voltage = 3 }
  ) { Coupled {Poisson Electron Hole Circuit} }
  
  ***********************************
  * small-signal Optical AC analysis
  ACCoupled( ACExtraction = "n@node@"
    StartFrequency=1e6 EndFrequency=1e10  NumberOfPoints=16  Decade
    Node(np nn)  Optical
  ) { Poisson Electron Hole }
}
