#setdep @previous@

File {
    Grid    = "@tdr@"
    plot    = "@tdrdat@"
    Current = "@plot@"
    Output  = "@log@"
    Parameters = "@parameter@"
    PMIPath="@pwd@"
}

Electrode {
    { Name="c1"    Voltage=0 }
    { Name="c2"    Voltage=0 }
}

Thermode {
    { Name="c1" temperature=300 }
    { Name="c2" temperature=300 }
}

Plot {
    LayerThickness
    Potential
    Doping
    eDensity hDensity
    ThermalConductivity
}

Physics (Material = "Silicon"){
  Mobility(dopingdep)
  LayerThickness
  ThermalConductivity (pmi_thinlayer_kappa)
}

Math {
    Iterations = 15
    ThinLayer()
}

Solve {
    Coupled(LineSearchDamping=0.1){ Poisson }

    Quasistationary(
      InitialStep=0.1 MaxStep=0.05 MinStep=0.01 
      Goal { Name = "c1" voltage =  1.6 }
    ){
      Coupled {  Poisson  Electron  Hole Temperature }
    }
}

