(display "define constants... \n")
(sde:clear)

;;geometry
(define mySubstrateThickness 5 ) ; um
(define myWidth 1 ); um
;; doping
(define mySubstrateDoping 2e16 ) ; cm^-3
(define myBackDopingConcentration 1e19 ) ; cm^-3
(define myBackDopingDepth 3 ) ; um
(define myFrontDopingConcentration 6e19 ) ; cm^-3
(define myFrontDopingDepth 0.15 ) ; um
;; refinements
(define myRefGlobalX 1)
(define myRefGlobalY 1)
(define myRefDopDiff 1)
;; others
(define myNode "@node@")

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:create-rectangle (position 0 0 0) 
       (position mySubstrateThickness myWidth 0) 
      "Silicon" "substrate")

;; ----------------------------------------
(display "place dopings ... \n")
;; constant substrate doping
(sdedr:define-constant-profile "substrateDop" "BoronActiveConcentration" mySubstrateDoping)
(sdedr:define-constant-profile-region "substrateDop" "substrateDop" "substrate")
;; Gaussian front doping
(sdedr:define-refeval-window "frontDop" "Line"  
      (position 0 0 0) 
      (position 0 myWidth 0))
(sdedr:define-gaussian-profile "frontDop" "PhosphorusActiveConcentration" 
      "PeakPos" 0  
      "PeakVal" myFrontDopingConcentration 
      "Length" myFrontDopingDepth 
      "Erf"  "Factor" 0.)
(sdedr:define-analytical-profile-placement "frontDop" "frontDop" "frontDop" "Both" "NoReplace" "Eval")
;; Gaussian back doping
(sdedr:define-refeval-window "backDop" "Line"  
      (position mySubstrateThickness 0 0) 
      (position mySubstrateThickness myWidth 0))
(sdedr:define-gaussian-profile "backDop" "BoronActiveConcentration" 
      "PeakPos" 0  
       "PeakVal" myBackDopingConcentration 
       "Length" myBackDopingDepth 
       "Erf"  "Factor" 0.8)
(sdedr:define-analytical-profile-placement "backDop" "backDop" "backDop" "Both" "NoReplace" "Eval")

;; ----------------------------------------
(display "define contacts... \n")
(sdegeo:define-contact-set "cathode" 4  (color:rgb 1 0 0 ) "##" )
(sdegeo:define-contact-set "anode" 4  (color:rgb 0 0 1 ) "##" )
(sdegeo:set-contact (find-edge-id (position 0 0.1 0)) "cathode")
(sdegeo:set-contact (find-edge-id (position mySubstrateThickness 0.1 0)) "anode")
(sde:refresh)
;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "global" myRefGlobalX  myRefGlobalY 0 myRefGlobalX myRefGlobalY 0 )
(sdedr:define-refinement-region "global" "global" "substrate" )
;; on doping
(sdedr:define-refinement-size "doping" 10 500 0 0.1 500 0 )
(sdedr:define-refinement-function "doping" "DopingConcentration" "MaxTransDiff" myRefDopDiff)
(sdedr:define-refinement-region "doping" "doping" "substrate" )

;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "-y 1e5" (string-append "n" myNode "_msh") ) ;;-y sets the max aspect ratio of the elements

(display "Done.")
