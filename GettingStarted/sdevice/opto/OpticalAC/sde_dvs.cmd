
(display "define constants... \n")
(sde:clear)

(sde:set-process-up-direction "+z")

;;geometry
(define substrateThickness 5 )  ; um
(define deviceWidth 5)    ; um
(define contactThickness 1 )  ; um
(define contactWidth 1)   ; um
;; doping
(define substrateDoping 2e16 )    ; cm^-3
(define nDopingConcentration 1e19 )   ; cm^-3
(define nDopingDepth 0.5 )    ; um
(define pDopingConcentration 6e19 )   ; cm^-3
(define pDopingDepth 0.3 )    ; um
;; refinements
(define refOpticsScale 1.2)
(define refOpticsMin 0.01)
(define refOpticsDepth 2)
(define refGlobalX 2)
(define refGlobalY 2)
(define refDopingDiff 1)
;; others
(define myNode "struct")

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle 
  (position 0 0 0) 
  (position deviceWidth substrateThickness 0) 
  "Silicon" "substrate")
;;-----
(display "  cathode metal")(newline)
(sdegeo:create-rectangle 
  (position 0 0 0) 
  (position contactWidth (- contactThickness) 0) 
  "Silver" "nContact")
;;-----
(display "  anode metal")(newline)
(sdegeo:create-rectangle 
  (position (- deviceWidth contactWidth) 0 0) 
  (position deviceWidth (- contactThickness) 0) 
  "Silver" "pContact")

;; ----------------------------------------
(display "place dopings ... \n")
(display "  substrate doping\n")
(sdedr:define-constant-profile "substrateDop" "BoronActiveConcentration" substrateDoping)
(sdedr:define-constant-profile-region "substrateDop" "substrateDop" "substrate")

;;-----
(display "  p-doping\n")
;;(sdedr:define-refinement-window "pDop" "Line"  
;;  (position 0 0 0)     
;;  (position contactWidth 0 0))
(sdedr:define-body-interface-refwin  (list
  (find-region-id "pContact")
  (find-region-id "substrate")) "pDop")
(sdedr:define-gaussian-profile "pDop" "BoronActiveConcentration" 
  "PeakPos" 0  
  "PeakVal" pDopingConcentration 
  "Length" pDopingDepth 
  "Erf"  "Factor" 0.5)
(sdedr:define-analytical-profile-placement "pDop" "pDop" "pDop" "Both" "NoReplace" "Eval")

;;-----
(display "  n-doping\n")
(sdedr:define-body-interface-refwin  (list
  (find-region-id "nContact")
  (find-region-id "substrate")) "nDop")
(sdedr:define-gaussian-profile "nDop" "PhosphorusActiveConcentration" 
  "PeakPos" 0  
  "PeakVal" nDopingConcentration 
  "Length" nDopingDepth 
  "Erf"  "Factor" 0.5)
(sdedr:define-analytical-profile-placement "nDop" "nDop" "nDop" "Both" "NoReplace" "Eval")

;; ----------------------------------------
(display "define contacts... \n")
(sdegeo:define-contact-set "cathode" 4  (color:rgb 0 0 1 ) "##" )
(sdegeo:set-current-contact-set "cathode")
(sdegeo:set-contact-boundary-edges (find-region-id "nContact"))
(sdegeo:define-contact-set "anode" 4  (color:rgb 1 0 0 ) "##" )
(sdegeo:set-current-contact-set "anode")
(sdegeo:set-contact-boundary-edges (find-region-id "pContact"))
(sde:refresh)

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "global" 
  refGlobalX  refGlobalY 
  refGlobalX refGlobalY )
(sdedr:define-refinement-region "global" "global" "substrate" )
;; on doping
(sdedr:define-refinement-size "doping" 
  deviceWidth substrateThickness 
  0.02 0.02 )
(sdedr:define-refinement-function "doping" "DopingConcentration" "MaxTransDiff" refDopingDiff)
(sdedr:define-refinement-region "doping" "doping" "substrate" )
;;optical refinement
(sdedr:define-refeval-window "optics" "Rectangle"
  (position contactWidth 0 0)
  (position (- deviceWidth contactWidth) refOpticsDepth 0))  
(sdedr:define-multibox-size "optics" 
  deviceWidth substrateThickness
  deviceWidth refOpticsMin
  1 refOpticsScale )
(sdedr:define-multibox-placement "optics" "optics" "optics" )

;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "" "n@node@" ) 

(display "Done.")
