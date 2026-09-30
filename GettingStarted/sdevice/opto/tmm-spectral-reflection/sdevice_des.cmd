*----------------------------------------
* Purpose: Simulate Reflectance with TMM
#setdep @previous@

*--------------------------------------------------
File {
  *-Input
  Grid  = "@tdr@"
  *-Output
  Plot = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
}

*--------------------------------------------------
Plot {
  AbsorbedPhotonDensity
  OpticalGeneration
  ComplexRefractiveIndex
}

*--------------------------------------------------
CurrentPlot{
  ModelParameter="Wavelength"
}

*--------------------------------------------------
Physics {
  Optics (
    ComplexRefractiveIndex (WavelengthDep(Real Imag))
    OpticalGeneration ( ComputeFromMonochromaticSource ) 
    Excitation (
      Wavelength = @wstart@  *[um]
      theta = 0 * angle of incidence from +y to +x axis
                * 0 points in +y direction, 90 in +x direction. 
      Intensity = 0.1 *[W/cm2]
      Polarization = 0.5 * TE, TM or a number P 0..1 where P = I_TE/I_tot  
      Window(
        Origin=(0,-@dSiN@)
        Line(x1=0 x2=1)
      )
    ) * end excitation
    OpticalSolver (
      TMM (
        LayerStackExtraction(
          Medium(
            Location = Bottom
            Material = "Silicon"
          )
        ) * end LayerStack
      ) * end TMM
    ) * end opticalSolver
  ) * end optics
} * end physics


*--------------------------------------------------
*Solve Section
Solve{
  *ramp through wavelength
  Quasistationary (  
    DoZero
    InitialStep = @<1./wsteps>@ MaxStep = @<1./wsteps>@ Minstep = @<1./wsteps>@
    Goal { modelParameter="Wavelength" value=@wend@ }
  ) {
    Optics
    # Plot(FilePrefix=n@node@ NoOverwrite)
  }
}
