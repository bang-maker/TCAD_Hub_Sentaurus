IOControls {
  InputFile = "@pwd@/@tdrboundary@"
  EnableSections
  UnstructuredTensorMesh=True
  Verbosity=3
}
#----------------------------------------
#if @example@ == 2
Definitions {
  Constant "substrate" {
    Species = "BoronActiveConcentration"
    Value = 1e+16
  }
  Constant "poly" {
    Species = "ArsenicActiveConcentration"
    Value = 1e+20
  }
  AnalyticalProfile "source.ext" {
    Species = "ArsenicActiveConcentration"
    Function = Gauss(
      PeakPos=0.007, PeakVal=8e+19, 
      ValueAtDepth=1e17, Depth=0.05
    )
    LateralFunction = Erf(Factor=0.2)
  }
  AnalyticalProfile "source" {
    Species = "ArsenicActiveConcentration"
    Function = Erf(SymPos=0.05, MaxVal=2.3e20, ValueAtDepth=1e17, Depth=0.1)
    LateralFunction = Erf(Factor=0.4)
  }
  AnalyticalProfile "sub" {
    Species = "BoronActiveConcentration"
    Function = Erf(SymPos=0.05, MaxVal=6e17, ValueAtDepth=1.5e16, Depth=1.5)
    LateralFunction = Erf(Factor=0.)
  }
}

Placements {
  Constant "substrate" {        
    Reference = "substrate"
    EvaluateWindow {
      Element = material ["Silicon"]
    }
  }
  Constant "poly" {        
    Reference = "poly"
    EvaluateWindow {
      Element = material ["PolySilicon"]
    }
  }
  AnalyticalProfile "source.ext" {
    Reference = "source.ext"
    ReferenceElement {
      Element = Line [(0.07 0) (0.365 0)]
    }
  }
  AnalyticalProfile "source" {
    Reference = "source"
    ReferenceElement {
      Element = Line [(0.145 0) (0.365 0)]
    }
  }
  AnalyticalProfile "sub" {
    Reference = "sub"
    ReferenceElement {
      Element = Line [(0 0) (0.365 0)]
    }
  }
}
Tensor {
  Mesh {
    numPointsX = 100
    numPointsY = 1000
  }
}

#----------------------------------------
#elif @example@ == 3
Definitions {
  Submesh "doping" { Geofile = "@pwd@/doping_msh.tdr" }
}

Placements {
  Submesh "doping" { Reference = "doping"  }
}
Tensor {
  Mesh {
    minCellSize direction "x" 0.005
    maxCellSize = 0.05
    window "active" 0 0.365 -0.2 0.2
    maxCellSize window direction "active" "y" 0.005
    window "channel" 0 0.15 -0.005 0.05
    maxCellSize window direction "channel" "y" 0.001
    window "source" 0.1 0.365 0.0 0.14
    maxCellSize window direction "source" "y" 0.002
  }
}
#endif
