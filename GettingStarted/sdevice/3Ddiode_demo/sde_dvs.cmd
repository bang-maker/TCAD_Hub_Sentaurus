; 3D diode structure generation
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")


(sdegeo:create-cuboid (position 0 0 0)  (position 1 1 10) "Silicon" "region_1")

(sdegeo:set-contact (list (car (find-face-id (position 0.5 0.5 10)))) "top")
(sdegeo:set-contact (list (car (find-face-id (position 0.5 0.5 0)))) "bottom")

(sdedr:define-refeval-window "top" "Rectangle"  
  (position -5 -5 10) (position 5 5 10))
(sdedr:define-analytical-profile-placement "top" "top" "top" 
  "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "top" "BoronActiveConcentration" 
  "PeakPos" 0  "PeakVal" 1e18 
  "ValueAtDepth" 1e10 "Depth" 8 
  "Gauss"  "Factor" 0.8)

(sdedr:define-refeval-window "bottom" "Rectangle"  
  (position -5 -5 0) (position 5 5 0))
(sdedr:define-analytical-profile-placement "bottom" "bottom" "bottom" 
  "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "bottom" "PhosphorusActiveConcentration" 
  "PeakPos" 0  "PeakVal" 1e18 
  "ValueAtDepth" 1e10 "Depth" 8 
  "Gauss"  "Factor" 0.8)

;(sdedr:define-constant-profile "dop" "PhosphorusActiveConcentration" 1e18)
;(sdedr:define-constant-profile-material "dop" "dop" "Silicon")


(define res 0.125)

(sdedr:define-refinement-size "global" res res res 0.01 0.01 0.01 )
(sdedr:define-refinement-placement "global" "global" (list "material" "Silicon" ))
(sdedr:define-refinement-function "global" "DopingConcentration" "MaxTransDiff" 1)

(sdesnmesh:delaunizer 
  "maxPoints" 1e6 
  "maxConnectivity" 120
  "delaunayTolerance" 0. 
  "minDihedralAngleAllowed" 1  
)

(sde:build-mesh "n@node@")
