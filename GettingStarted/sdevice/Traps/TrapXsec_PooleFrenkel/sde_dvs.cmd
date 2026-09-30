
(sdegeo:create-rectangle (position -2. -0.5 0.0 )  (position 2. 0.5 0.0 ) "Silicon" "region_1" )
(sdegeo:set-contact (list (car (find-edge-id (position -2. 0.0 0))) ) "c1")
(sdegeo:set-contact (list (car (find-edge-id (position  2. 0.0 0))) ) "c2")

;dopings
(sdedr:define-refeval-window "p-baseline" "Line"  
      (position -2 1.0921317338943 0)  (position -2 -0.69919538497925 0))
(sdedr:define-analytical-profile-placement "boron-placement" "boron-definition" "p-baseline" "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "boron-definition" "BoronActiveConcentration" "PeakPos" 0  
       "PeakVal" @p_peak@ "ValueAtDepth" @n_dop_conc@ "Depth" 2 "Gauss"  "Factor" 0.8)
       
(sdedr:define-constant-profile "background" "PhosphorusActiveConcentration" @n_dop_conc@)
(sdedr:define-constant-profile-material "background" "background" "Silicon")
(sdedr:define-refeval-window "default" "Rectangle"  (position -2.1 -0.5574 0)  (position 2.1 0.5712 0) )
(sdedr:define-refinement-size "default" 0.02 0.5 0.5 0.001 0.1 0.1 )
(sdedr:define-refinement-material "default" "default" "Silicon" )
(sdedr:define-refinement-function "default" "DopingConcentration" "MaxTransDiff" 1)

(sde:build-mesh "n@node@")
