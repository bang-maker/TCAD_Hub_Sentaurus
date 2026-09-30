#setdep @node|rectangle@

(sde:clear)

(sdegeo:create-cuboid (position 0 -1 0) (position 1 3.0 2.0) "Silicon" "bulk")

(sdedr:define-refeval-window "RefEvalWin_1" "Cuboid"  
  (position 0 0 0) (position 1 2.0 2.0))

#(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
#  "ExternalProfileDefinition_1" "RefEvalWin_1" "NoReplace" "Rotation" 90 "X")
(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
  "ExternalProfileDefinition_1" "RefEvalWin_1" "NoReplace")
(sdedr:define-submesh "ExternalProfileDefinition_1" 
  "n@node|rectangle@_Ext1D_2D_msh.tdr")


(sdedr:define-refeval-window "RefEvalWin_2" "Rectangle"  
  (position 0 2.0 0) (position 1 2.0 2.0))
(sdegeo:sweep (find-drs-id "RefEvalWin_2") (position 0 2.0 0) (gvector 0 0 1) 
  (sweep:options "solid" #t "sweep_angle" 90 "rigid" #f "miter_type" "default"))

(sdedr:define-submesh-placement "ExternalProfilePlacement_2" 
  "ExternalProfileDefinition_1" "RefEvalWin_2" "NoReplace" "Rotation" 90 "X")


(sdedr:define-refeval-window "RefEvalWin_3" "Rectangle"  
  (position 0 0.0 0) (position 1 0.0 2.0))
(sdegeo:sweep (find-drs-id "RefEvalWin_3") (position 0 0.0 0) (gvector 0 0 1) 
  (sweep:options "solid" #t "sweep_angle" -90 "rigid" #f "miter_type" 
    "default"))

(sdedr:define-submesh-placement "ExternalProfilePlacement_3" 
  "ExternalProfileDefinition_1" "RefEvalWin_3" "NoReplace" "Rotation" 90 "X")

(sdedr:define-refinement-size "RefinementDefinition_1" 
  0.15 0.15 0.15 0.02 0.02 0.02 )
(sdedr:define-refinement-material "RefinementPlacement_1" 
  "RefinementDefinition_1" "Silicon" )
(sdedr:define-refinement-function "RefinementDefinition_1" 
  "ArsenicActiveConcentration" "MaxTransDiff" 1)

(sde:build-mesh "n@node@_sweep2D3D_msh")
