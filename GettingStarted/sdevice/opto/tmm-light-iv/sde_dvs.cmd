;;-----------------------------------------
;; Simple 2D planar solar cell structure 
;; Author: Gergoe Letay

(display "define constants... \n")
!(
set wtot 300
set wfront 10
)!
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

;;geometry
(define mySubstrateThickness 50 ) ; um
(define myWidth !(puts -nonewline $wtot)! ); um
(define myFrontContactThickness 5 ); um
(define myFrontContactWidth !(puts -nonewline $wfront)!); um
(define myBackContactWidth 300); um
(define myFrontArcThickness 0.075 ); um
;; doping
(define mySubstrateDoping 2e16 ) ; cm^-3
(define myBackDopingConcentration 1e19 ) ; cm^-3
(define myBackDopingDepth 3 ) ; um
(define myFrontDopingConcentration 6e19 ) ; cm^-3
(define myFrontDopingDepth 0.15 ) ; um
;; refinements
(define myRefOptScale 1.2)
(define myRefOptYmin 0.001)
(define myRefOptDepth 15)
(define myRefGlobalX 100)
(define myRefGlobalY 10)
(define myRefDopDiff 1)
(define myRefFrontContactOffset 2)
(define myRefFrontContactX 2)
;; others
(define myNode "@node@")

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:create-rectangle (position 0 0 0) 
       (position myWidth mySubstrateThickness 0) 
      "Silicon" "substrate")
(display "  front ARC")(newline)
(sdegeo:create-rectangle (position 0 (- myFrontArcThickness) 0) 
      (position myWidth  0 0) 
      "Nitride" "frontArc")
(if (> myFrontContactWidth 0)
  (begin
    (display "  front Contact metal")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle (position 0 (- myFrontContactThickness) 0) 
      (position myFrontContactWidth 0 0) 
      "Silver" "frontContact")
    ));endif

;; ----------------------------------------
(display "place dopings ... \n")
;; constant substrate doping
(sdedr:define-constant-profile "substrateDop" "BoronActiveConcentration" mySubstrateDoping)
(sdedr:define-constant-profile-region "substrateDop" "substrateDop" "substrate")
;; Gaussian front doping
(sdedr:define-refeval-window "frontDop" "Line"  
      (position 0 0 0) 
      (position myWidth 0 0))
(sdedr:define-gaussian-profile "frontDop" "PhosphorusActiveConcentration" 
      "PeakPos" 0  
      "PeakVal" myFrontDopingConcentration 
      "Length" myFrontDopingDepth 
      "Erf"  "Factor" 0.)
(sdedr:define-analytical-profile-placement "frontDop" "frontDop" "frontDop" "Both" "NoReplace" "Eval")
;; Gaussian back doping
(sdedr:define-refeval-window "backDop" "Line"  
      (position 0 mySubstrateThickness 0) 
      (position  myBackContactWidth mySubstrateThickness 0))
(sdedr:define-gaussian-profile "backDop" "BoronActiveConcentration" 
      "PeakPos" 0  
       "PeakVal" myBackDopingConcentration 
       "Length" myBackDopingDepth 
       "Erf"  "Factor" 0.)
(sdedr:define-analytical-profile-placement "backDop" "backDop" "backDop" "Both" "NoReplace" "Eval")

;; ----------------------------------------
(display "define contacts... \n")
(sdegeo:define-contact-set "cathode" 4  (color:rgb 1 0 0 ) "##" )
(sdegeo:define-contact-set "anode" 4  (color:rgb 0 0 1 ) "##" )
(sdegeo:set-contact (find-edge-id (position 0.1 0 0)) "cathode")
(sdegeo:set-contact (find-edge-id (position 0.1 mySubstrateThickness 0)) "anode")
(sde:refresh)
;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "global" myRefGlobalX  myRefGlobalY 0 myRefGlobalX myRefGlobalY 0 )
(sdedr:define-refinement-region "global" "global" "substrate" )
;; on doping
(sdedr:define-refinement-size "doping" 500 10 0 500 0.1 0 )
(sdedr:define-refinement-function "doping" "DopingConcentration" "MaxTransDiff" myRefDopDiff)
(sdedr:define-refinement-region "doping" "doping" "substrate" )
;; front contact
(if (> myFrontContactWidth 0)
  (begin
(sdedr:define-refeval-window "frontContact" "Rectangle"  
                                (position 0 0 0)  
                                (position (+ myFrontContactWidth myRefFrontContactOffset) 2 0) )
(sdedr:define-refinement-size "frontContact" myRefFrontContactX 10 0 (/ myRefFrontContactX 2) 10 0 )
(sdedr:define-refinement-placement "frontContact" "frontContact" "frontContact" )
  ));endif	
;;optical refinement
(sdedr:define-refeval-window "optics" "Rectangle"  
                                (position myFrontContactWidth  0 0)  
                                (position myWidth myRefOptDepth 0) )
(sdedr:define-multibox-size "optics" 500 10 500 myRefOptYmin 0 myRefOptScale )
(sdedr:define-multibox-placement "optics" "optics" "optics" )

;; ----------------------------------------
(display "build mesh... \n")
(sdesnmesh:axisaligned "maxAspectRatio" 1e5)
(sde:build-mesh (string-append "n" myNode "_msh") ) ;;-y sets the max aspect ratio of the elements

(display "Done.")
