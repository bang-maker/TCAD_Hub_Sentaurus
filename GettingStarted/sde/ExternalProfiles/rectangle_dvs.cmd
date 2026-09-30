(sde:clear)

(sdegeo:create-rectangle (position 0 0 0) (position 1 2 0) "Silicon" "r1")

(sdedr:define-refeval-window "RefEvalWin_1" "Line"  
  (position 0.0 0.5 0) (position 0.0 1.5 0))
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_1" 
  "AnalyticalProfileDefinition_1" "RefEvalWin_1" "Both" "NoReplace" "Eval")
(sdedr:define-1d-external-profile "AnalyticalProfileDefinition_1" 
  "1d_As.plx" "Scale" 1.0   "Gauss"  "Factor" 0.2)

(sdedr:define-refinement-size "RefinementDefinition_1" 0.2 0.2 0.001 0.001 )
(sdedr:define-refinement-material "RefinementPlacement_1" 
  "RefinementDefinition_1" "Silicon" )
(sdedr:define-refinement-function "RefinementDefinition_1" 
  "ArsenicActiveConcentration" "MaxTransDiff" 0.5)

(sde:build-mesh "n@node@_Ext1D_2D_msh")
