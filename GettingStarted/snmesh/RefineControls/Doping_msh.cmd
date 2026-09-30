Title "Example: Mesh refine on doping"

Definitions {
  Constant "ConstantProfileDefinition_1" {
    Species = "BoronActiveConcentration"
    Value = 1e+16
  }
  AnalyticalProfile "AnalyticalProfileDefinition_1" {
  Species = "PhosphorusActiveConcentration"
  Function = Gauss(PeakPos= 0, PeakVal= 1e+18, ValueAtDepth = 1e+16, Depth = 1)
  LateralFunction = Erf(Factor = 0.8)
  }
  Refinement "global" {
    MaxElementSize = ( 0.2 0.2 0.2 )
    MinElementSize = ( 0.01 0.01 0.01 )
#if "@DopRefType@" == "MaxTransDiff"
    RefineFunction = MaxTransDiff(Variable="DopingConcentration", Value=@Value@)
#elif "@DopRefType@" == "MaxGradient"
    RefineFunction = MaxGradient(Variable="DopingConcentration", Value=@Value@)
#elif "@DopRefType@" == "MaxInterval"
    RefineFunction = MaxInterval(Variable = "DopingConcentration", 
    	cmin = 1e16, cmax = 1e17, targetLength = 0.01
    ) 
#endif
  }
}

Placements {
  Constant "ConstantProfilePlacement_1" {
    Reference = "ConstantProfileDefinition_1"
    EvaluateWindow {
      Element = material ["Silicon"]
    }
  }
  AnalyticalProfile "AnalyticalProfilePlacement_1" {
    Reference = "AnalyticalProfileDefinition_1"
    ReferenceElement {
      Element = Line [(0 0.5) (0 1.5)]
    }
  }
  Refinement "global" {
    Reference = "global"
    RefineWindow = material ["Silicon"]
  }
}
