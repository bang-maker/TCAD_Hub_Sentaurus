Title "3D device simulation, dopants deatomized in SMesh"

IOControls {
  InputFile = "@pwd@/@tdrboundary@"
}

Definitions {
  Constant "PolyDoping" {
    Species = "ArsenicActiveConcentration"
    Value   = 1e+20
  }
  
  Particle "BoronParticles" {
    ParticleFile = "@pwd@/kmc_final.tdr"
    Species = "BoronActiveConcentration"
    ScreeningFactor = 3.5e6
    AutoScreeningFactor
    Normalization
  }
  
  Particle "ArsenicParticles" {
    ParticleFile = "@pwd@/kmc_final.tdr"
    Species = "ArsenicActiveConcentration"
    ScreeningFactor = 1.1e7
    AutoScreeningFactor
    Normalization
  }
  
  Refinement "Default Region" {
    MaxElementSize = (0.01 4     1.0)
    MinElementSize = (0.01 0.06  0.01)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 0.6)
  }
  
  Refinement "channel_1" {
    MaxElementSize = (0.01 0.00125 0.0004)
    MinElementSize = (0.01 0.001         0.0002)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 0.4)
  }
  
  Refinement "channel_2" {
    MaxElementSize = (0.01 0.00125  0.002)
    MinElementSize = (0.01 0.001          0.001)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 0.4)
  }
  
  Refinement "channel_3" {
    MaxElementSize = (0.01 0.00125  0.010)
    MinElementSize = (0.01 0.001          0.005)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 0.2)
  }
  
  Refinement "extension" {
    MaxElementSize = (0.01 0.0025  0.010)
    MinElementSize = (0.01 0.00125  0.005)
  }
  
  Refinement "well" {
    MaxElementSize = (0.01 4    0.2)
    MinElementSize = (0.01 0.1  0.1)
  }
  
  Refinement "pn-junction_SD" {
    MaxElementSize = (0.01 0.016 0.02)
    MinElementSize = (0.01 0.004 0.01)
  }
  
  Refinement "Interface" {
    RefineFunction = MaxLenInt(Interface("Silicon","Oxide"), Value=0.0008, factor=2)
  }
  
  Constant "substrate" {
    Species = "BoronActiveConcentration"
    Value   = 1e16
  }
}

Placements {
  Constant "PolyDopingPlacement" {
    Reference = "PolyDoping"
    EvaluateWindow {
      Element = material ["PolySilicon"]
    }
  }
  
  Particle "ArsenicPlacement" {
    Reference = "ArsenicParticles"
    EvaluateWindow {
      Element=material ["Silicon"]
    }
  }
  
  Particle "BoronPlacement" {
    Reference = "BoronParticles"
    EvaluateWindow { 
      Element=material ["Silicon"]
    }
  }
  
  Constant "substrate" {
    Reference = "substrate"
    EvaluateWindow  {
      Element = material ["Silicon"]        
    }
  }
  
  Refinement "Default Region" {
    Reference = "Default Region"
  }
  
  Refinement "channel_1" {
    Reference = "channel_1"
    RefineWindow = cuboid [
    (0.0 -0.0245  -0.002),
    (0.05  0.0245   0.0)
    ]
  }
  
  Refinement "channel_2" {
    Reference = "channel_2"
    RefineWindow = cuboid [
    (0.0 -0.0245  -0.005),
    (0.05  0.0245   0.002)
    ]
  }
  
  Refinement "channel_3" {
    Reference = "channel_3"
    RefineWindow = cuboid [
    (0.0 -0.0275  -0.02),
    (0.05  0.0275   0.01)
    ]
  }
  
  Refinement "extension" {
    Reference = "extension"
    RefineWindow = cuboid [
    (0.0 -0.0875  -0.02),
    (0.05  0.0875   0.0)
    ]
  }
  
  Refinement "well" {
    Reference = "well"
    RefineWindow = cuboid [
    (0.0        -100.  -0.45),
    (0.05  100.   0.03)
    ]
  } 
  
  Refinement "pn-junction_SD" {
    Reference = "pn-junction_SD"
    RefineWindow = cuboid [
    (0.0        -100.  -0.1),
    (0.05  100.   0.02)
    ]
  }
  
  Refinement "Interface" {
    Reference = "Interface"
    RefineWindow = cuboid [
    (0.0  -100.  -0.02),
    (0.05 100.  0.0)
    ]
  }
}



