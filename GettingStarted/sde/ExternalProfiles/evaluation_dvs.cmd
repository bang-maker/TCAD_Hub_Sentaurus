#setdep @node|rectangle@

(sde:clear)

(sdegeo:create-cuboid (position 0 -1 0) (position 1 3.0 2.0) "Silicon" "bulk")


#if @case@==0
(sdedr:define-refeval-window "RefEvalWin_1" "Cuboid"  
  (position 0 0 0) (position 1 2.0 2.0))
(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
  "ExternalProfileDefinition_1" "RefEvalWin_1" "NoReplace")

(sdedr:define-submesh "ExternalProfileDefinition_1" 
  "n@node|rectangle@_Ext1D_2D_msh.tdr")

#endif

#if @case@==1
(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
  "ExternalProfileDefinition_1" "bulk" "PlacementType" "Region" "NoReplace")

(sdedr:define-submesh "ExternalProfileDefinition_1" 
  "n@node|rectangle@_Ext1D_2D_msh.tdr")

#endif




(sdedr:define-refinement-size "RefinementDefinition_1" 
  0.15 0.15 0.15 0.02 0.02 0.02 )
(sdedr:define-refinement-material "RefinementPlacement_1" 
  "RefinementDefinition_1" "Silicon" )
(sdedr:define-refinement-function "RefinementDefinition_1" 
  "ArsenicActiveConcentration" "MaxTransDiff" 1)

(sde:build-mesh "n@node@_2D3D_msh")



