  Electrode {
   { name="1"   Voltage=0.0 }
   { name="2"   Voltage=0.0 }
  }
  File {
    Grid     = "@tdr@"        * device structure/grid/doping in tdr-format
    Plot     = "@tdrdat@"     * output file to plot 2D/3D fields with Tecplot
  }
  
  Physics {
    Mobility( DopingDep )     * turns on mobility doping dependency

    Traps(                    
      ( Donor                 * electron trap level (synonym of eNeutral)
        Level                 * trap level localized at single energy position
        fromMidBandGap        * energy center of trap distribution at mid band gap (ref point)
        EnergyMid=0.          * trap level shift from the ref point, [eV]
        Conc=1e18             * trap concentration, [1/cm^3]
        eXsection=1e-14       * trap cross-section to capture an electron, [cm^2]
        hXsection=1e-14       * trap cross-section to capture a hole, [cm^2]
#if "@add2total@" == "yes"
        Add2TotalDoping
#endif                
      )
    )
  }
  Plot {
    Doping
    eMobility hMobility
  }

  Solve {
    coupled (Iterations=100 LineSearchDamping=0.1) { Poisson }
    coupled (Iterations=100 LineSearchDamping=0.1) { Poisson Electron Hole }

  }
