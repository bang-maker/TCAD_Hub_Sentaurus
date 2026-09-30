#setdep @node|rectangle@
(sde:clear)

(sdegeo:create-rectangle (position 0 0 0) (position 1.5 5 0) "Silicon" "r1")

#===============================================
#if @case@==0
(sdedr:define-refeval-window "RefEvalWin_1" "Rectangle"  
  (position 0 2 0) (position 1 4 0))
                

(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
  "ExternalProfileDefinition_1" "RefEvalWin_1" "NoReplace")
(sdedr:clear-submesh-placement-transform "ExternalProfilePlacement_1")
(sdedr:transform-submesh-placement "ExternalProfilePlacement_1"
  "ShiftVector" (gvector 0 2 0))

(sdedr:define-submesh "ExternalProfileDefinition_1" 
  "n@node|rectangle@_Ext1D_2D_msh.tdr")


(sdegeo:sweep (find-material-id "Silicon") (position 0 0 0) (gvector 1 0 0) 
  (sweep:options "solid" #t "sweep_angle" 270 "rigid" #f "miter_type" 
    "default"))
(sdegeo:sweep (find-drs-id "RefEvalWin_1") (position 0 0 0) (gvector 1 0 0) 
  (sweep:options "solid" #t "sweep_angle" 270 "rigid" #f "miter_type" 
    "default"))

#===============================================
#elif @case@==1
(define path2 (sdegeo:create-polyline-wire (list 
  (position 0.0 2.5 0.0)
  (position 0.0 2.5 -2.0) 
  (position 0.0 2.4 -3.0)  
  (position 0.0 1.0 -4.0)
  (position 0.0 1.0 -5.0)
  (position 0.0 2.0 -6.0)
  (position 0.0 4.0 -7.0) 
  (position 0.0 7.0 -8.0) 
  )))


(sdedr:define-refeval-window "RefEvalWin_1" "Rectangle"  
  (position 0 2 0) (position 1 4 0))

(sdedr:define-submesh-placement "ExternalProfilePlacement_1" 
  "ExternalProfileDefinition_1" "RefEvalWin_1" "NoReplace")
(sdedr:clear-submesh-placement-transform "ExternalProfilePlacement_1")
(sdedr:transform-submesh-placement "ExternalProfilePlacement_1" 
  "ShiftVector" (gvector 0 2 0))

(sdedr:define-submesh "ExternalProfileDefinition_1" 
  "n@node|rectangle@_Ext1D_2D_msh.tdr")

(sdegeo:sweep (entity:faces (find-material-id "Silicon")) path2  
  (sweep:options "solid" #t "rigid" #f "miter_type" "default"  ))
(map bool:regularise (get-body-list))

(sdegeo:sweep (find-drs-id "RefEvalWin_1") path2  
  (sweep:options "solid" #t "rigid" #f "miter_type" "default"  ))

#endif


(sdedr:define-refinement-size "RefinementDefinition_1" 
  0.2 0.5 0.5 0.05 0.05 0.05 )
(sdedr:define-refinement-material "RefinementPlacement_1" 
  "RefinementDefinition_1" "Silicon" )
(sdedr:define-refinement-function "RefinementDefinition_1" 
  "ArsenicActiveConcentration" "MaxTransDiff" 1)

(sde:build-mesh "n@node@_advanced_sweep2D3D_msh")
