;;-----------------------------------------
;; Simple 2D Solar Cell structure 
;; $Id: //tcad/support/main/examples/opto/solarcell/si/simple/sc-reflectance/sde_dvs.cmd#4 $
;; Author: Gergoe Letay

(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

(display "define constants... \n")
;;geometry
(define dsub 2 ) ; um
(define myWidth 1 ); um
(define myFrontArcThickness @dSiN@ ); um
;; doping
(define Ndop 2e16 ) ; cm^-3
;; refinements
(define myRefGlobalX 1)
(define myRefGlobalY 0.1)
;; others
(define myNode "@node@")

;; ----------------------------------------
(display "create structure... \n")
;; substrate
(sdegeo:create-rectangle (position 0 0 0) 
  (position myWidth dsub 0) 
  "Silicon" "substrate")
;; front ARC
(sdegeo:create-rectangle 
  (position 0 (- myFrontArcThickness) 0) 
  (position myWidth  0 0) 
  "Nitride" "frontArc")
(sdegeo:set-default-boolean "ABA")

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "global" myRefGlobalX  myRefGlobalY 0 myRefGlobalX myRefGlobalY 0 )
(sdedr:define-refinement-region "global" "global" "substrate" )

;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "n@node@" ) 

(display "Done.")