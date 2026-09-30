; Reinitializing SDE 
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

; Selecting default Boolean expression 
(sdegeo:set-default-boolean "ABA")

; Creating rectangular regions  
(sdegeo:create-rectangle
  (position -0.5  0.2   0.0) (position 0.5  1.0   0.0) 
  "Silicon" "R.Substrate"
) 
(sdegeo:create-rectangle
  (position -0.5  0.1   0.0) (position 0.5  0.2  0.0) 
  "Oxide" "R.Box"
)
(sdegeo:create-rectangle
  (position -0.5  0.0   0.0) (position 0.5  0.1   0.0) 
  "Silicon" "R.Siliconepi"
) 
(sdegeo:create-rectangle
  (position -0.2 -40e-4 0.0) (position 0.2  0.0   0.0) 
  "Oxide" "R.Gateox"
)
(sdegeo:create-rectangle
  (position -0.2 -0.2   0.0) (position 0.2 -40e-4 0.0) 
  "Nitride" "R.Spacer"
)
(sdegeo:create-rectangle
  (position -0.1 -0.2   0.0) (position 0.1 -40e-4 0.0) 
  "PolySilicon" "R.Polygate"
)

; Rounding edges
(sde:define-parameter "fillet-radius" 0.08 0.0 0.0 )
(sdegeo:fillet-2d (find-vertex-id (position -0.2 -0.2 0.0)) fillet-radius)
(sdegeo:fillet-2d (find-vertex-id (position  0.2 -0.2 0.0)) fillet-radius)

; Defining contacts 
(sdegeo:set-contact (find-edge-id (position -0.4  0.0 0.0)) "source")
(sdegeo:set-contact (find-edge-id (position  0.4  0.0 0.0)) "drain")
(sdegeo:set-contact (find-body-id (position 0.0 -0.1 0.0)) "gate" "remove")
(sdegeo:set-contact (find-edge-id (position  0.0  1.0 0.0)) "substrate")
; Adding extra vertices for bodytie contact
(sdegeo:insert-vertex (position -0.1  0.1 0.0))
(sdegeo:insert-vertex (position -0.05 0.1 0.0))
(sdegeo:set-contact (find-edge-id (position -0.07 0.1 0.0)) "bodytie")

;-------------------------------------------------------------------------------
;-- Specification of doping profiles to be inluded during meshing --------------
;-------------------------------------------------------------------------------

; Defining constant doping levels in a material
(sdedr:define-constant-profile "Const.Silicon" "BoronActiveConcentration" 1e+15)
(sdedr:define-constant-profile-material "PlaceCD.Silicon" 
  "Const.Silicon" "Silicon") 

; Defining constant doping levels in a region
(sdedr:define-constant-profile "Const.Epi" "BoronActiveConcentration" 1e17)
(sdedr:define-constant-profile-region "PlaceCD.Epi" "Const.Epi" "R.Siliconepi")

; Defining analytic doping profiles
; Step 1: base line definitions
(sdedr:define-refeval-window "BaseLine.Source" 
  "Line" (position -0.8 0.0 0.0) (position -0.2 0.0 0.0))
(sdedr:define-refeval-window "BaseLine.Drain" 
  "Line" (position  0.2 0.0 0.0) (position  0.8 0.0 0.0))
(sdedr:define-refeval-window "BaseLine.SourceExt" 
  "Line" (position -0.8 0.0 0.0) (position -0.1 0.0 0.0))
(sdedr:define-refeval-window "BaseLine.DrainExt" 
  "Line" (position  0.1 0.0 0.0) (position  0.8 0.0 0.0))

; Step 2: Profile and placement definitions
(sdedr:define-analytical-profile-placement "PlaceAP.Source"
  "Gauss.SourceDrain" "BaseLine.Source" "Positive" "NoReplace" "Eval")

(sdedr:define-gaussian-profile "Gauss.SourceDrain"
  "ArsenicActiveConcentration" "PeakPos" 0.0 "PeakVal" 5e19
  "ValueAtDepth" 1e17 "Depth" 0.12 "Gauss" "Factor" 0.8)

(sdedr:define-analytical-profile-placement "PlaceAP.Drain"
  "Gauss.SourceDrain" "BaseLine.Drain" "Positive" "NoReplace" "Eval")

(sdedr:define-analytical-profile-placement "PlaceAP.SourceExt"
  "Gauss.SourceDrainExt" "BaseLine.SourceExt" "Positive" "NoReplace" "Eval")

(sdedr:define-gaussian-profile "Gauss.SourceDrainExt"
  "ArsenicActiveConcentration" "PeakPos" 0.0 "PeakVal" 5e18
  "ValueAtDepth" 1e17 "Depth" 0.035 "Gauss" "Factor" 0.8)

(sdedr:define-analytical-profile-placement "PlaceAP.DrainExt"
  "Gauss.SourceDrainExt" "BaseLine.DrainExt" "Positive" "NoReplace" "Eval")

; Saving the model
(sde:save-model "n@node@_dop")
