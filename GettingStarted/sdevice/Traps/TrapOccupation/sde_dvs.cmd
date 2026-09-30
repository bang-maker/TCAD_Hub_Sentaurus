#if "@type@" == "p"
(define Dtype "BoronActiveConcentration")
#else
(define Dtype "PhosphorusActiveConcentration")
#endif

(sdegeo:create-rectangle (position -0.5 -0.5 0.0 )  (position 0.5 0.5 0.0 ) "Silicon" "region_1" )
(sdegeo:set-contact (list (car (find-edge-id (position -0.5 0.0 0))) ) "c1")
(sdegeo:set-contact (list (car (find-edge-id (position 0.5 0.0 0))) ) "c2")

(sdedr:define-constant-profile "background" Dtype 1e17)
(sdedr:define-constant-profile-material "background" "background" "Silicon")
(sdedr:define-refeval-window "default" "Rectangle"  (position -0.5563 -0.5574 0)  (position 0.5766 0.5712 0) )
(sdedr:define-refinement-size "default" 0.05 0.05 0.05 0.01 0.01 0.01 )
(sdedr:define-refinement-material "default" "default" "Silicon" )

(sde:build-mesh "n@node@")
