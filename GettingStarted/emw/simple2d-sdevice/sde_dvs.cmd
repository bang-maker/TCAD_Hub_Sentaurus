;;-----------------------------------------
;; $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple2d-sdevice/sde_dvs.cmd#1 $
;; Author: Gergoe Letay
(sde:clear)
(sde:set-process-up-direction "+z")

;;--------------------
(display "init parameter")(newline)
;;geometry
(define dair 1) ; um
(define dsub 1) ; um
(define wtot @wtot@); um
;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle (position 0 0 0) (position wtot  dsub 0) "Silicon" "substrate")

;;--------------------
(display "fill with gas")(newline)
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle (position 0 0 0) (position wtot (- dair) 0) "Gas" "ambient")

;;--------------------
(display "save boundary")(newline)
(sdeio:save-tdr-bnd "all" "@tdrboundary/o@")

;; ----------------------------------------
(display "place dopings ... \n")
;; constant substrate doping
(sdedr:define-constant-profile "substrateDop" "BoronActiveConcentration" 2e16)
(sdedr:define-constant-profile-region "substrateDop" "substrateDop" "substrate")
;; Gaussian front doping
(sdedr:define-refeval-window "frontDop" "Line"  
  (position 0 0 0) 
  (position wtot 0 0))
(sdedr:define-gaussian-profile "frontDop" "PhosphorusActiveConcentration" 
  "PeakPos" 0   "PeakVal" 6e19 "Length" 0.15 "Erf"  "Factor" 0.)
(sdedr:define-analytical-profile-placement "frontDop" "frontDop" "frontDop" "Both" "NoReplace" "Eval")

;; ----------------------------------------
(display "define contacts... \n")
(sdegeo:set-contact (find-edge-id (position (/ wtot 2) 0 0)) "nContact")
(sdegeo:set-contact (find-edge-id (position (/ wtot 2) dsub 0)) "pContact")

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "ref.global" 1 0.1 0 1 0.1 0 )
(sdedr:define-refeval-window "win.global" "Rectangle"  
  (position 0 0 0)  
  (position wtot dsub  0) )
(sdedr:define-refinement-placement "ref.global" "ref.global" "win.global" )
;; on doping
(sdedr:define-refinement-size "doping" 500 10 0 500 0.1 0 )
(sdedr:define-refinement-function "doping" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-region "doping" "doping" "substrate" )   
;; maximum aspect ratio of elements
(sdesnmesh:axisaligned 
	"maxAspectRatio" 1e5
)

;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "n@node@_el" )

(display "done.")(newline)
