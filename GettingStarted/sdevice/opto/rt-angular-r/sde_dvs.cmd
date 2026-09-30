;; ------------------------------------------------------------
;; purpose: create a simple Si block with surrounding air
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

(display "define constants... \n")
;; refinement
(define ym 0.1 ) ; um
(define xm 0.1 ) ; um
;; node number for output file
(define node "@node@")

;; ----------------------------------------
(display "create structure... \n")
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle 
  (position 0 0 0 )  
  (position 1 1 0 ) 
  "Silicon" "substrate" )

(sdegeo:create-rectangle 
  (position 0 -0.2 0 )  
  (position 1 0 0 ) 
  "Gas" "top_air" )

(sdegeo:create-rectangle 
  (position 0 1 0 )  
  (position 1 1.2 0 ) 
  "Gas" "bottom_air" )

(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle 
  (position -0.2 -0.4 0 )  
  (position 1.2 1.4 0 ) 
  "Gas" "outside" )

;; ----------------------------------------
(display "add refinements... \n")
;; global refinement
(sdedr:define-refeval-window "global" "Rectangle" 
  (position -0.2 -1.4 0)  
  (position 1.2 1.4 0))
(sdedr:define-refinement-size "global" xm ym 0 xm ym 0)
(sdedr:define-refinement-placement "global" "global" "global" )

;;----------------------------------------
(display "generate mesh ... \n")
(sde:build-mesh "n@node@")

(display "Done.\n")
