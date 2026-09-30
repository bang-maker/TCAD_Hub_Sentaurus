; Reinitializing SDE
(sde:clear)



; Creating polygonal  regions
(sdegeo:create-polygon 
 (list  (position 0.6 -0.45  0.0)
        (position 0.6  1.2   0.0)
        (position 0.3  1.2   0.0)
        (position 0.3  1.095 0.0)
        (position 0.0  1.005 0.0)
        (position 0.0  0.795 0.0)
        (position 0.3  0.705 0.0)
        (position 0.3  0.315 0.0)
        (position 0.0  0.225 0.0)
        (position 0.0 -0.225 0.0)
        (position 0.3 -0.315 0.0)
        (position 0.3 -0.45  0.0) 
        (position 0.6 -0.45  0.0) )
 "Silicon" "Substate") 

; Creating rectangular regions  
(sdegeo:create-rectangle
  (position -0.075 -0.225 0.0) (position   0.0 0.225  0.0) "SiliconGermanium" "SiGeBase")
(sdegeo:create-rectangle
  (position -0.075 -0.6  0.0) (position -0.15 -0.15 0.0) "PolySilicon" "Baseleft")
(sdegeo:create-rectangle
  (position  -0.075  0.15 0.0) (position  -0.15 0.45  0.0) "PolySilicon" "Baseright")
(sdegeo:create-rectangle
  (position -0.075 -0.075 0.0) (position  -0.3 0.075  0.0) "PolySilicon" "Emitter")
(sdegeo:create-rectangle
  (position  0.0 0.825   0.0) (position  -0.3 0.975  0.0) "Aluminium" "CollectorCont")
(sdegeo:create-rectangle
  (position -0.15 -0.6  0.0) (position -0.3 -0.45  0.0) "Aluminium" "BaseCont")

; Creating device insulation using overlap resolution 
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle
  (position -0.3 -0.6  0.0) (position  0.6 1.35  0.0) "Oxide" "Insulation")

; Defining contacts 
(sdegeo:set-contact (find-body-id (position -0.225 -0.525  0.0)) "base" "remove")
(sdegeo:set-contact (find-body-id (position -0.15   0.9    0.0)) "collector" "remove")
(sdegeo:set-contact (find-edge-id (position -0.3    0.0    0.0)) "emitter")

; Refinement Boxes
(sdedr:define-refeval-window "BulkP" "Rectangle"  
  (position -0.2 -0.65  0.0)  (position 0.6 1.4  0.0) )

(sdedr:define-refeval-window "PolysTop" "Rectangle"  
  (position -0.16 -0.65  0.0)  (position -0.05 0.50  0.0) )

(sdedr:define-refeval-window "Collector" "Line"  
  (position -0.075 -0.45  0.0)  (position -0.075 1.20  0.0) )

(sdedr:define-refeval-window "Base" "Line"  
  (position -0.075 -0.225  0.0)  (position -0.075 0.225  0.0) )

; Doping Windows
; Doping Definitions
; Doping Placements

(sdedr:define-constant-profile "lowP" "BoronActiveConcentration" 1.45e15)

(sdedr:define-constant-profile-placement "baseColl" "lowP" "BulkP")

(sdedr:define-constant-profile "hiP" "BoronActiveConcentration" 9.20e+19)

(sdedr:define-constant-profile-region "polyLeftP+" "hiP" "Baseleft")

(sdedr:define-constant-profile-region "polyRightP+" "hiP" "Baseright")

(sdedr:define-constant-profile "N95e19" "ArsenicActiveConcentration" 9.65e+19)

(sdedr:define-constant-profile-region "poly_emitter" "N95e19" "Emitter")


(sdedr:define-analytical-profile-placement "collectorN" "Nplus2.6e19" 
  "Collector" "Both" "NoReplace" "Eval")

(sdedr:define-gaussian-profile "Nplus2.6e19"
  "ArsenicActiveConcentration" "PeakPos" 0.0  "PeakVal" 2.6e19 
  "ValueAtDepth" 1.45e15 "Depth" 0.650 "Gauss"  "Factor" 0.001)

(sdedr:define-refeval-window "Base" "Line"  
 (position -0.075 -0.225  0.0)  (position -0.075 0.225  0.0) )

(sdedr:define-analytical-profile-placement "baseP" 
  "Pplus4.27e19" "Base" "Both" "NoReplace" "Eval")

(sdedr:define-gaussian-profile "Pplus4.27e19" 
  "BoronActiveConcentration" "PeakPos" 0.0  "PeakVal" 4.27e19 
  "ValueAtDepth" 2.42e19 "Depth" 0.075 "Gauss"  "Factor" 0.001)

; Saving the model
(sde:save-model "sigehbt_dop")

; Refinement Boxes

(sdedr:define-refeval-window "GlobalRefinement" "Rectangle"  
  (position -0.4 -0.65  0.0)  (position 0.7 1.45  0.0) )

(sdedr:define-refeval-window "PolysTop" "Rectangle"  
  (position -0.16 -0.65  0.0)  (position -0.05 0.50  0.0) )

(sdedr:define-refeval-window "base_refine" "Rectangle"  
  (position -0.1 -0.25  0.0)  (position 0.025 0.25  0.0) )

(sdedr:define-refeval-window "collector_refineL" "Rectangle"  
  (position 0.025 -0.35  0.0)  (position 0.40 0.45  0.0) )
 
(sdedr:define-refeval-window "collector_refineR" "Rectangle"  
  (position  0.025 0.50  0.0)  (position 0.40 1.15  0.0) )

; Doping Windows
; Doping Definitions
; Doping Placements

(sdedr:define-refinement-size "DefaultCourse" 0.08 0.1  0.02  0.05 )

(sdedr:define-refinement-placement "default" "DefaultCourse" "GlobalRefinement" )

(sdedr:define-refinement-function "DefaultCourse" "DopingConcentration" "MaxTransDiff" 1.0)

(sdedr:define-refinement-size "DefaultCourse1" 0.02 0.04  0.005 0.005 )

(sdedr:define-refinement-placement "top" "DefaultCourse1" "PolysTop" )

(sdedr:define-refinement-function "DefaultCourse1" "DopingConcentration" "MaxTransDiff" 1.000000)

(sdedr:define-refinement-size "Base1" 0.010 0.08  0.004 0.020  )

(sdedr:define-refinement-placement "BasePlace" "Base1" "base_refine" )

(sdedr:define-refinement-function "Base1" "DopingConcentration" "MaxTransDiff" 1.0)

(sdedr:define-refinement-size "Collector1" 0.040 0.08  0.01 0.040  )

(sdedr:define-refinement-placement "CollectorPlaceL" "Collector1" "collector_refineL" )

(sdedr:define-refinement-placement "CollectorPlaceR" "Collector1" "collector_refineR" )

(sdedr:define-refinement-function "Collector1" "DopingConcentration" "MaxTransDiff" 0.5)

; Meshing the device structure 
(sde:build-mesh "n@node@")
