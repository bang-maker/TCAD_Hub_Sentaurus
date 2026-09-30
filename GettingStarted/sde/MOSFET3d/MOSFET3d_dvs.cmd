; Reinitializing SDE 
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

(sdegeo:set-default-boolean "ABA")

; Creating cuboid regions
(sdegeo:create-cuboid (position -0.25 -0.2 0) (position 0.25 0.2 -1.0)  
 "Silicon" "SubsSilicon")
 
(sdegeo:create-cuboid (position -0.15 -0.1 0) (position 0.15 0.1 0.002)  
 "Oxide" "GateOxide")

(sdegeo:create-cuboid (position -0.2 -0.2 0) (position 0.2 -0.1 -0.2)  
 "Oxide" "TrenchOxide_Right")

(sdegeo:create-cuboid (position -0.2  0.1 0) (position 0.2  0.2 -0.2)  
 "Oxide" "TrenchOxide_Left")

(sdegeo:create-cuboid (position -0.1 -0.1 0.002) (position 0.1 0.2 0.1)  
 "PolySi" "PolyGate")

; Poly Reoxidation
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid (position -0.103 -0.103 0) (position 0.103 0.2 0.1)  
 "Oxide" "PolyReOxide1")

(sdegeo:create-cuboid (position -0.15 -0.15 0) (position 0.15 0.2 0.005)
  "Oxide" "PolyReOxide2")

; Ni Spacers
(sdegeo:create-cuboid (position -0.15 -0.15 0) (position 0.15 0.2 0.08)  
 "Nitride" "NiSpacer")

(sde:define-parameter "fillet-radius" 0.03 0.0 0.0 )

(sdegeo:fillet 
 (list (car (find-vertex-id (position -0.15 -0.15 0.08))) 
       (car (find-vertex-id (position  0.15 -0.15 0.08))) ) fillet-radius)

; Contact definitions
(sdegeo:set-contact (find-face-id (position 0 0 -1) ) "substrate")  
(sdegeo:set-contact (find-face-id (position 0 0 0.1)) "gate")  

(define SOURCE 
	(sdegeo:create-cuboid (position -0.25 -0.1 0) (position -0.17  0.1 0.05)
	"Metal" "Source"))
(sdegeo:set-contact SOURCE "source" "remove")  

(define DRAIN 
	(sdegeo:create-cuboid (position  0.17  -0.1 0) (position  0.25 0.1 0.05)
	"Metal" "Drain"))
(sdegeo:set-contact DRAIN "drain" "remove")  

; Constant doping profile definions
(sdedr:define-constant-profile "Const.Bulk" "BoronActiveConcentration" 1e17)
(sdedr:define-constant-profile-region "PlaceCD.Bulk"
  "Const.Bulk" "SubsSilicon")

(sdedr:define-constant-profile "Const.Poly" "ArsenicActiveConcentration" 1e20)
(sdedr:define-constant-profile-region "PlaceCD.Poly"
  "Const.Poly" "PolyGate")

; Analytic doping profile definions
(sdedr:define-refeval-window "BaseLine.Source" "Rectangle"  
 (position  0.30 -0.25 0.0)  (position 0.15 0.25 0.0) )

(sdedr:define-refeval-window "BaseLine.Drain" "Rectangle" 
 (position -0.30 -0.25 0.0)  (position -0.15 0.25  0.0) )

(sdedr:define-gaussian-profile "Gauss.SourceDrain"
  "ArsenicActiveConcentration" "PeakPos" 0.0 "PeakVal" 1e19
  "ValueAtDepth" 1e17 "Depth" 0.1 "Gauss" "Factor" 0.8)

(sdedr:define-analytical-profile-placement "PlaceAP.Source"
 "Gauss.SourceDrain" "BaseLine.Source" "Both" "NoReplace" "Eval")

(sdedr:define-analytical-profile-placement "PlaceAP.Drain"
 "Gauss.SourceDrain" "BaseLine.Drain" "Both" "NoReplace" "Eval")

; Meshing strategies
(sdedr:define-refeval-window "RefWin.Global" "Cuboid"
  (position -0.25 -0.2 -1.0) (position 0.25 0.2 0.1))

(sdedr:define-refinement-size "RefDef.Global"
  0.1  0.1  0.1
  0.05 0.05 0.05 )

(sdedr:define-refinement-placement "Place.Global"
 "RefDef.Global" "RefWin.Global" )

(sdedr:define-refeval-window "RefWin.Active" "Cuboid"
 (position -0.25 -0.2 -0.15) (position 0.25 0.2 0.0))

(sdedr:define-refinement-size "RefDef.Active"
  0.025  0.025  0.025
  0.0125 0.0125 0.0125 )

(sdedr:define-refinement-placement "Place.Active"
"RefDef.Active" "RefWin.Active")

; Multiboxes
(sdedr:define-refeval-window "RefWin.Channel"
 "Cuboid" (position -0.12 -0.1 -0.05) (position 0.12 0.1 0))
 
(sdedr:define-multibox-size "RefDefMB.Channel"
 0.1  0.1  0.01
 0.05 0.05 0.001
 1    1   -1.5 )

(sdedr:define-multibox-placement "PlaceMB.Channel"
  "RefDefMB.Channel" "RefWin.Channel" )

; Meshing structure 
(sde:build-mesh "n@node@")


