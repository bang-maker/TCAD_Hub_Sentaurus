File {
  PMIPath    = "@pwd@"
  Parameters = "@parameter@"
  Current    = "@plot@"
  Output     = "@log@"
}

Plot {
  MSConfig
}

Device "PCMCELL" {
  File {
    Grid       = "@pwd@/pcm_structure_msh.tdr"
  }
  
  Electrode {
    { Name="top"      Voltage=0 }
    { Name="bottom"   Voltage=0 }
  }
  
  Thermode {
    { name="top" Temperature=300 SurfaceResistance = 1e-5 }
    { name="bottom" Temperature=300 SurfaceResistance = 1e-5 }
  }
  
  Plot {
    eTrappedCharge hTrappedCharge SpaceCharge
    Doping ElectricField BuiltinPotential
    BandGap ConductionBand ValenceBand
    eMobility hMobility
    TotalCurrent/vector eCurrent/vector hCurrent/Vector CurrentPotential
    TotalHeat eJouleHeat hJouleHeat ThermalConductivity LatticeHeatCapacity
    DeepLevels
    MSConfig
    eQDDShiftMSConfig hQDDShiftMSConfig
    eTrappedCharge hTrappedCharge
    eGapStatesRecombination hGapStatesRecombination
  }  

  CurrentPlot {
    pmi_cp
    eQDDShiftMSConfig (
      Maximum(Material="GST")
      Minimum(Material="GST")
      Integrate(Material="GST")
      Average(Material="GST")
    )
    hQDDShiftMSConfig (
      Maximum(Material="GST")
      Minimum(Material="GST")
      Integrate(Material="GST")
      Average(Material="GST")
    )
  }
  
  Physics {
    Temperature=300.
    EffectiveIntrinsicDensity(NoBandGapNarrowing)
    ThermalConductivity (TempDep Conductivity)	
    HeatCapacity(TempDep)
  }
  
  Physics (Material="GST") {
    ThermalConductivity (
      PMIModel (Name="pmi_msc_thermalconductivity" MSConfig="ca")
    )
    HeatCapacity (
      PMIModel (Name="pmi_msc_heatcapacity" MSConfig="ca")
    )
    eQuantumPotential
    hQuantumPotential
    eMobility (
      DopingDep(
        PMIModel( Name = "pmi_msc_mobility" MSConfig = "ca" String="e" )
      )
    )
    hMobility(
      DopingDep(
        PMIModel( Name = "pmi_msc_mobility" MSConfig = "ca" String="h" )
      )
    )
    MSConfigs (
      *** MSC representing a 3-phase model with exactly one trap
      MSConfig ( Name = "ca" Conc = 1.e18 -Elimination
        
        *** states
        State ( Name = "c" )	* crystalline
        State ( Name = "a" )	* amorphous
        State ( Name = "m" )	* melt
        State ( Name = "c100" Charge = -1 )
        State ( Name = "a100" Charge = -1 )
        State ( Name = "m100" Charge = -1 )
        
        *** phase transitions for not-occupied states
        Transition(Name="t0" to="c" from="a" CEModel("pmi_ce_msc" 0))
        Transition(Name="t1" to="c" from="a" CEModel("pmi_ce_msc" 1))
        Transition(Name="t2" to="c" from="m" CEModel("pmi_ce_msc" 2))
        Transition(Name="t3" to="a" from="m" CEModel("pmi_ce_msc" 3))
        
        *** exchange with CB
        Transition(Name="t100" to="c100" from="c" CEModel("pmi_ce_msc" 100)
        Reservoirs("CB"(Particles=1)) )
        
        Transition(Name="t1100" to="a100" from="a" CEModel("pmi_ce_msc" 1100)
        Reservoirs("CB"(Particles=1)) )
        
        Transition(Name="t2100" to="m100" from="m" CEModel("pmi_ce_msc" 2100)
        Reservoirs("CB"(Particles=1)) )
        
        *** exchange with VB
        Transition(Name="t50100" to="c" from="c100" CEModel("pmi_ce_msc" 50100)
        Reservoirs("VB"(Particles=1)) )
        
        Transition(Name="t51100" to="a" from="a100" CEModel("pmi_ce_msc" 51100)
        Reservoirs("VB"(Particles=1)) )
        
        Transition(Name="t52100" to="m" from="m100" CEModel("pmi_ce_msc" 52100)
        Reservoirs("VB"(Particles=1)) )
        
        *** phase transitions for occupied states
        Transition(Name="t30" to="c100" from="a100" CEModel("pmi_ce_msc" 30))
        Transition(Name="t31" to="c100" from="a100" CEModel("pmi_ce_msc" 31))
        Transition(Name="t32" to="c100" from="m100" CEModel("pmi_ce_msc" 32))
        Transition(Name="t33" to="a100" from="m100" CEModel("pmi_ce_msc" 33))
        
        eBandEdgeShift ( "pmi_msc_abes" 0 )
        hBandEdgeShift ( "pmi_msc_abes" 1 )
      )
    )
  }

  Physics(MaterialInterface = "TiN/GST"){ MSPeltierHeat }
  
  Math {}
}

System {
  Electrical (na nt ng)
  PCMCELL "cell" ("top"=nt "bottom"=ng)
  Resistor_pset "Rload" (na nt) { resistance=1000. }
  Vsource_pset "Va" (na 0) {
    pwl = (
      0.          0.
      1e-09       4.2
      20e-9       4.2
      2.0001e-08  0.2
      5.e-7       0.2
      1.5e-06     4.2
      1.501e-06   0.2
      2e-06       0.2
    )
  }
  Plot "n@node@_reset_set_circ_des.plt" ( time()
    v(na) v(nt) v(ng)
    i(cell ng) i(cell nt)
    i(Rload nt) i(Rload na)
  )
  set (ng=0)
}

Math {
  RhsMax = 1.e100
  ExitOnFailure
  Extrapolate
  Transient = BE
  Iterations=20
  Method=Pardiso
}

Solve {
  Coupled { Poisson Circuit Contact }
  
  Coupled { Poisson Electron Hole Temperature
    eQuantumPotential hQuantumPotential
  Contact TContact Circuit TCircuit }
  Plot ( FilePrefix = "n@node@_reset_set_init_coupled" ) 
  
  NewCurrentFile = "reset_set_RESET_" 
  Transient (
    InitialTime=0. FinalTime =5.e-7
    InitialStep=1e-10 MinStep=1e-13 MaxStep=0.1
    Increment=1.41
  ) {
    Coupled { Poisson Electron Hole Temperature
      eQuantumPotential hQuantumPotential
    Contact TContact Circuit TCircuit } 
  }    
  Plot ( FilePrefix = "n@node@_reset_set_final" )
}


