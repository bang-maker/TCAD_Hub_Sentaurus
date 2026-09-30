(sde:clear)

(define dx 0.1)
(define dy 1.0)

(sdegeo:create-rectangle (position (* 0 dx) 0 0) (position (* 1 dx) dy 0) "Silicon" "region_1")
(sdegeo:create-rectangle (position (* 1 dx) 0 0) (position (* 2 dx) dy 0) "SiliconGermanium" "region_2")
(sdegeo:create-rectangle (position (* 2 dx) 0 0) (position (* 3 dx) dy 0) "Silicon" "region_3")

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")

(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_1" "linear" "" "Positive" "Replace" "Eval")
(sdedr:define-analytical-profile "linear" "PhosphorusActiveConcentration" "fmax=10^18;fmin=10^16" "10.*(fmin-fmax)*x+2.*fmax-fmin" 0.0 "general")
(sdedr:define-constant-profile "ConstantProfileDefinition_1" "PhosphorusActiveConcentration" 1e18)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_1" "ConstantProfileDefinition_1" "region_1"  0 "Replace")
(sdedr:define-constant-profile "ConstantProfileDefinition_2" "PhosphorusActiveConcentration" 1e+16)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_2" "ConstantProfileDefinition_2" "region_3"  0 "Replace")
(sdedr:define-refeval-window "RefEvalWin_1" "Rectangle"  (position 0 0 0)  (position 1 0.3 0) )
(sdedr:define-refinement-size "RefinementDefinition_1" 0.5 0.01 0 0.1 0.001 0 )
(sdedr:define-refinement-placement "RefinementPlacement_1" "RefinementDefinition_1" "RefEvalWin_1" )
(sdedr:write-cmd-file "n@node@_msh.cmd")

;----------------------------------------------------------
; Meshing the device
;---------------------------------------------------
(sde:build-mesh "n@node@")

