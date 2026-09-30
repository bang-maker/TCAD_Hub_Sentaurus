Title "adaptive 3D mesh refinement using general function evaluator"

Definitions {
  Refinement "adaptive" {
    MaxElementSize=(0.5,0.5,0.5)
    MinElementSize=(0.01, 0.01, 0.01)
    RefineFunction = MaxTransDiff(Variable = "P2", Value=1.)
  }
  AnalyticProfile "gfe_profile" {
    Species = "P2"
    Function = General(init="c0=10^5;lx=0.1;ly=0.1;lz=0.1",
               function="c0/exp((x/lx)^2)/exp((y/ly)^2)/exp((z/lz)^2)")
  }
}
Placements {
  Refinement "adaptive" {
    Reference = "adaptive"
  }
  AnalyticProfile "gfe_profile" {
    Reference = "gfe_profile"
    EvaluateWindow { Element = Material ["Silicon"] }
  }
}
AxisAligned {
  MaxNeighborRatio=8
}  
