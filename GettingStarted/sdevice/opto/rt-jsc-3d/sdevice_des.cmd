*----------------------------------------
* $Id: //tcad/support/main/examples/opto/solarcell/si/simple/sc-iv-light/sdevice_des.cmd#8 $
* Author: Gergoe Letay
*- Purpose: Simulate electrics/optics for light IV 
#setdep @previous@

*--------------------------------------------------
File {
  *-Input
  Grid    = "@tdr@"
  IlluminationSpectrum = "@pwd@/am15g.txt"
  *-Output
  Plot    = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
}

*--------------------------------------------------
Electrode {   
  { name="cathode" voltage=0.0 }
  { name="anode" voltage=0.0 }
}

*--------------------------------------------------
Plot {
  SRH Auger
  AbsorbedPhotonDensity
  OpticalGeneration
  QuantumYield
  ComplexRefractiveIndex
  # Raytrees
}

*--------------------------------------------------
CurrentPlot{
  OpticalGeneration(Integrate(Semiconductor) ) 
  AbsorbedPhotonDensity(Integrate(Semiconductor) ) 
}

*--------------------------------------------------
Physics (RegionInterface="top_air/substrate") {
  RayTraceBC(
    TMM(
      ReferenceRegion = "top_air" 
      LayerStructure {
        75e-3 "Nitride"
      }
    )
  )
  Recombination(SurfaceSRH)
}

*--------------------------------------------------
Physics (RegionInterface="bottom_air/substrate") {
  RayTraceBC(Reflectivity=0 Transmittivity=0)
}

*--------------------------------------------------
Physics (RegionInterface="substrate/outside") {
  RayTraceBC(Reflectivity=1)
}

*--------------------------------------------------
Physics (RegionInterface="top_air/outside") {
  RayTraceBC(Reflectivity=0 Transmittivity=0)
}

*--------------------------------------------------
Physics (RegionInterface="bottom_air/outside") {
  RayTraceBC(Reflectivity=0 Transmittivity=0)
}

*--------------------------------------------------
Physics {
  * only a quarter of the structure is simulated, hence, multiply currents by 4
  # Area=4 
  Recombination( SRH(DopingDependence) Auger )
  Mobility( DopingDep )
  Optics (
    ComplexRefractiveIndex (
      WavelengthDep(Real Imag)
    )
    OpticalGeneration (
      Scaling=0
      * generated carriers/photon, default: 1
      QuantumYield(StepFunction(EffectiveBandgap)) 
      ComputeFromSpectrum(
        Select(
          Parameter= ("Wavelength")
          Condition = "$wavelength <= 1.2"
        )
      ) * end ComputeFromSpectrum
    ) * end OpticalGeneration
    Excitation (
      fromTop
      PolarizationAngle = 45.
      Window ( 
        * required to shift the excitation plane down from the very top 
        * to within top_air just above the metal
        Origin = (-1.2, 2.5, 2.5)
        * required to neglect the outside region
        Rectangle(dx=5 dy=5)
      ) * end Window
      * These are the complete settings fromTop does automatically for you, 
      * they are partially overwritten as needed. also check the log.
      #if 0
      Theta=90 * angle of incidence from +z to +x axis
               * 0 points in +z direction, 90 in +x direction.         
      Phi=0    * second rotation of excitation direction from +x to +y around z
               * e.g. with theta=90, phi=0 points in +x direction, phi=90 in +y.
      Window ( 
        Origin = (-1.2, 2.5, 2.5)
        xDirection=(0,0,1)
        yDirection=(0,1,0)
        Rectangle(dx=5 dy=5)
      ) 
      #endif
    )
    OpticalSolver (
      RayTracing (
        RayDistribution(
          Mode=Equidistant
          Dx=0.5
          Dy=0.5
        )
        # CompactMemoryOption
        MonteCarlo
        MinIntensity = 1e-4
        DepthLimit = 1000
      ) *end TMM
    ) * end OpticalSolver
  ) * end Optics
} * end physics

*--------------------------------------------------
Solve{
  NewCurrentPrefix="tmp_"
  Poisson
  Coupled (Iterations=100) { poisson electron hole  }
  Quasistationary ( 
    InitialStep= 1e-1 MaxStep= 0.5
    -Extrapolate * better convergence when switching on light
    Goal { ModelParameter= "Scaling" Value= 100 }
  ){
    Coupled(Iterations=12) {Poisson Electron Hole}
  }
  NewCurrentPrefix=""
  Coupled { poisson electron hole }
}
