; Parameterization
(define tox 0.01)
(define mat "GaN")

; Boundary
;----------------------------------------------------------------------;
(sdegeo:create-rectangle 
    (position (- tox) -0.1 0) (position 0 0.1 0) 
    "Oxide" "R.gox"
)
(sdegeo:create-rectangle 
    (position 0 -0.1 0) (position 0.2 0.1 0) 
    mat "R.subs"
)

;----------------------------------------------------------------------;
; Define electrodes
;----------------------------------------------------------------------;
(sdegeo:define-contact-set "gate")
(sdegeo:set-current-contact-set "gate")
(sdegeo:set-contact-edges (find-edge-id (position (- tox) 0 0)))

(sdegeo:define-contact-set "subs")
(sdegeo:set-current-contact-set "subs")
(sdegeo:set-contact-edges (find-edge-id (position 0.2 0 0)))

;----------------------------------------------------------------------;
; Doping
;----------------------------------------------------------------------;
(sdedr:define-constant-profile "CP.bg" "nSiliconActiveConcentration" 2e17)
(sdedr:define-constant-profile-material "CP.bg" "CP.bg" mat)

; ----------------------------------------------------------------------------------
; Grid refinement definitions
; ----------------------------------------------------------------------------------
(sdedr:define-refinement-size "Ref.global" 0.01 99 0.005 88)
(sdedr:define-refinement-function "Ref.global" "MaxLenInt" mat "Oxide" 2e-4 1.1)
(sdedr:define-refinement-material "Ref.global" "Ref.global" mat)

; ----------------------------------------------------------------------------------
; Build mesh
; ----------------------------------------------------------------------------------
(sde:build-mesh "snmesh" "-H -AI" "n@node@_msh")


