*------------------------------------------------------------
*--      Simple illuminated pn junction
*------------------------------------------------------------
#setdep @previous@

*--------------------------------------------------
File {
  *-Input
  Grid    = "@[relpath n@node|sde@_el_msh.tdr]@"
  Parameters ="@parameter@"
  OpticalGenerationInput = "@[relpath n@node|emw@_g_eml.tdr]@"
  *-Output
  Plot    = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
}

*--------------------------------------------------
Electrode {   
  { name="nContact" voltage=0.0 }
  { name="pContact" voltage=0.0 }
}

*--------------------------------------------------
Plot {
  OpticalGeneration
  AbsorbedPhotonDensity
}

*--------------------------------------------------
CurrentPlot{
  OpticalGeneration(Integrate(Semiconductor) ) 
}

*--------------------------------------------------
Physics {
  Area = @<1e11/wtot>@ * to get current in mA/cm^2
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
      QuantumYield(StepFunction(EffectiveBandgap)) 
      ReadFromFile(Datasetname=AbsorbedPhotonDensity)
    ) * end OpticalGeneration
  ) * end optics
} * end physics

*--------------------------------------------------
Solve{
  Poisson
  Coupled (Iterations=100) { poisson electron hole  }
}
