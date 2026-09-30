File {
  grid    = "@tdr@"
  plot    = "@tdrdat@"
}


Electrode {
        { name="c1" voltage=0.0}  
  { name="c2" voltage=0.0}       
}



Physics {
  Traps(
   #if "@spatial_dist@" == "none"
    (@trap_type@ Conc=@conc@)
   #elif "@spatial_dist@" == "sfactor"
    (@trap_type@ Conc=@conc@ SFactor="DeepLevels")
   #elif "@spatial_dist@" == "spatialshape" && "@trap_type@" == "FixedCharge"
    (name="st1" FixedCharge Conc=@conc@ SpatialShape= Uniform SpaceMid=(-0.2,-0.2,0) SpaceSig=(0.04,0.08,100))
   #elif "@spatial_dist@" == "spatialshape" && "@trap_type@" == "Multiple_Traps"
    (name="st1" FixedCharge Conc=@conc@ SpatialShape= Uniform SpaceMid=(-0.2,-0.2,0) SpaceSig=(0.04,0.08,100))
    (name="st2" hNeutral Conc=@conc@ EnergyMid=0 SpatialShape= Gaussian SpaceMid=(0,0,0) SpaceSig=(0.04,0.025,100))
   #endif
  )  
}


#if "@spatial_dist@" == "spatialshape" && "@trap_type@" == "Multiple_Traps"
Physics (RegionInterface="region_1/region_2"){
   Traps(      
    (name="st3" eNeutral Conc=1e13 EnergyMid=0 SpatialShape= Uniform SpaceMid=(0,0.25,0) SpaceSig=(100,0.05,100))
   )
}
#endif



Plot {
        Potential ElectricField
        Doping eDensity hDensity SpaceCharge
      eTrappedCharge hTrappedCharge
      DeepLevels
      TotalTrapConcentration
}

Math {
  
}


Solve {
  Poisson
}




