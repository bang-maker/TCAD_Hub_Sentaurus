*------------------------------------------------------------
*-- Purpose: Simulate angular dependent reflectance with raytracer

#setdep @previous@
*--------------------------------------------------
File {
  grid  = "@tdr@"
  Plot = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
}

*--------------------------------------------------
* Fresnel at air/Si interface, this is defailt however defining it explicitly 
* will plot interface flux into the plt file
Physics(RegionInterface="top_air/substrate") {
  RayTraceBC (Fresnel)
}

* absorptive BC at the side walls of Si
Physics(RegionInterface="substrate/outside") {
  RayTraceBC (Reflectivity=1)
}

* absorptive BC at the bottom of Si
Physics(RegionInterface="substrate/bottom_air") {
  RayTraceBC (Reflectivity=0 Transmittivity=0)
}

* absorptive BC for the rest
Physics(MaterialInterface="Gas/Gas") {
  RayTraceBC (Reflectivity=0 Transmittivity=0)
} 

*--------------------------------------------------
Plot {
  ComplexRefractiveIndex
  RayTrees
}

*--------------------------------------------------
* plot excitation angle theta in plt file
CurrentPlot{
  ModelParameter="Theta"
}

*--------------------------------------------------
Physics {
  Optics (
    ComplexRefractiveIndex()
    OpticalGeneration (
      ComputeFromMonochromaticSource
    )
    Excitation (
      Theta = 0
      Polarization = @pol@
      Wavelength = 0.6 * um
      Intensity= 0.1 * [W/cm2]
      Window(
        * place illumination window slightly above top surface
        Origin=(0, -0.001) 
        Line(x1=0 x2=1)
      )
    )
    OpticalSolver (
      RayTracing (
        RayDistribution(
          Mode=AutoPopulate
          NumberOfRays = 1
        )
        MinIntensity = 1e-4
        DepthLimit = 10000
        # CompactMemoryOption
        PlotInterfaceFlux
      )
    )
  )
} * end global physics

*--------------------------------------------------
Solve {
  Quasistationary (
    DoZero
    InitialStep=@<1./179>@ MaxStep=@<1./179>@ Minstep=@<1./179>@
    # Plot { Range = (0 1) Intervals = 179 }
    Goal {ModelParameter="Theta" value= 89.5 }
  ) { 
    Optics 
  }   
}



