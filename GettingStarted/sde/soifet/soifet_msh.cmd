Definitions {
	Constant "Const.Silicon" {
		Species = "BoronActiveConcentration"
		Value = 1e+15
	}
	Constant "Const.Epi" {
		Species = "BoronActiveConcentration"
		Value = 1e+17
	}
	AnalyticalProfile "Gauss.SourceDrain" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 5e+19, ValueAtDepth = 1e+17, Depth = 0.12)
		LateralFunction = Gauss(Factor = 0.8)
	}
	AnalyticalProfile "Gauss.SourceDrainExt" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 5e+18, ValueAtDepth = 1e+17, Depth = 0.035)
		LateralFunction = Gauss(Factor = 0.8)
	}
	Refinement "RefDef.all" {
		MaxElementSize = ( 0.25 0.1 )
		MinElementSize = ( 0.25 0.1 )
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
		RefineFunction = MaxLenInt(Interface("Silicon","SiO2"), Value=0.001, factor=1.5, DoubleSide)
	}
	Refinement "RefDef.Epi" {
		MaxElementSize = ( 0.1 0.0125 )
		MinElementSize = ( 0.0025 0.0025 )
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
		RefineFunction = MaxLenInt(Interface("R.Siliconepi","R.Gateox"), Value=0.0002, factor=1.5, DoubleSide, UseRegionNames)
	}
	Refinement "RefDef.channel" {
		MaxElementSize = ( 0.25 0.1 )
		MinElementSize = ( 0.025 0.01 )
	}
}

Placements {
	Constant "PlaceCD.Silicon" {
		Reference = "Const.Silicon"
		EvaluateWindow {
			Element = material ["Silicon"]
		}
	}
	Constant "PlaceCD.Epi" {
		Reference = "Const.Epi"
		EvaluateWindow {
			Element = region ["R.Siliconepi"]
		}
	}
	AnalyticalProfile "PlaceAP.Source" {
		Reference = "Gauss.SourceDrain"
		ReferenceElement {
			Element = Line [(-0.8 0) (-0.2 0)]
			Direction = positive
		}
	}
	AnalyticalProfile "PlaceAP.Drain" {
		Reference = "Gauss.SourceDrain"
		ReferenceElement {
			Element = Line [(0.2 0) (0.8 0)]
			Direction = positive
		}
	}
	AnalyticalProfile "PlaceAP.SourceExt" {
		Reference = "Gauss.SourceDrainExt"
		ReferenceElement {
			Element = Line [(-0.8 0) (-0.1 0)]
			Direction = positive
		}
	}
	AnalyticalProfile "PlaceAP.DrainExt" {
		Reference = "Gauss.SourceDrainExt"
		ReferenceElement {
			Element = Line [(0.1 0) (0.8 0)]
			Direction = positive
		}
	}
	Refinement "PlaceRF.all" {
		Reference = "RefDef.all"
		RefineWindow = Rectangle [(-1 -0.5) (1 1.5)]
	}
	Refinement "PlaceRF.Epi" {
		Reference = "RefDef.Epi"
		RefineWindow = region ["R.Siliconepi"]
	}
	Refinement "PlaceRF.channel" {
		Reference = "RefDef.channel"
		RefineWindow = Rectangle [(-0.1 0) (0.1 0.1)]
	}
}

