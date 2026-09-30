;;-----------------------------------------
(display "define constants... \n")
(sde:clear)

;;geometry
(define substrateThickness 5 ) ; um
(define deviceWidth 5); um
(define contactThickness 1 ); um
(define contactWidth 1); um
(define contactFingerLength 3); um
;; doping
(define substrateDoping 2e16 ) ; cm^-3
(define nDopingConcentration 1e19 ) ; cm^-3
(define nDopingDepth 0.5 ) ; um
(define pDopingConcentration 6e19 ) ; cm^-3
(define pDopingDepth 0.3 ) ; um
;; refinements
(define refOpticsScale 1.2)
(define refOpticsMin 0.2)
(define refOpticsDepth 2)
(define refGlobalX 2)
(define refGlobalY 2)
(define refGlobalZ 1)
(define refDopingDiff 1)

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-cuboid 
  (position 0 0 0) 
  (position substrateThickness deviceWidth deviceWidth ) 
  "Silicon" "substrate")
;;-----
(display "  cathode metal")(newline)
(sdegeo:create-cuboid 
  (position 0 0 0) 
  (position (- contactThickness) deviceWidth deviceWidth ) 
  "Silver" "nContact")
(define delme (sdegeo:create-cuboid 
  (position 0 0 0) 
  (position (- contactThickness) (- deviceWidth contactWidth) (- deviceWidth contactWidth)) 
  "XX" "XX"))
(entity:delete delme)
;;-----
(display "  anode metal")(newline)
(define c1 
  (sdegeo:create-cuboid 
    (position 0 0 0) 
    (position (- contactThickness) contactWidth contactFingerLength ) 
    "Silver" "pContact"))
(define c2 
  (sdegeo:create-cuboid 
    (position 0 0 0) 
    (position (- contactThickness) contactFingerLength contactWidth) 
    "Silver" "pContact"))
(sdegeo:bool-unite (list c1 c2))
;; here the imprint should be recreated
(sde:bool-regularise (get-body-list))
(sde:fix-imprint)

;;-----
(display "  top air")(newline)
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid 
  (position 0 0 0) 
  (position (- -1 contactThickness) deviceWidth deviceWidth ) 
  "Gas" "top_air")

;;-----
(display "  bottom air")(newline)
(sdegeo:create-cuboid 
  (position substrateThickness 0 0 ) 
  (position (+ 1 substrateThickness) deviceWidth deviceWidth ) 
  "Gas" "bottom_air")

;;-----
(display "  outside")(newline)
(sdegeo:create-cuboid 
  (position (- -1.2 contactThickness ) -0.2 -0.2 ) 
  (position (+ 1.2 substrateThickness) (+ deviceWidth 0.2) (+ deviceWidth 0.2) ) 
  "Gas" "outside")

;; ----------------------------------------
(display "place dopings ... \n")
(display "  substrate doping\n")
(sdedr:define-constant-profile "substrateDop" "BoronActiveConcentration" substrateDoping)
(sdedr:define-constant-profile-region "substrateDop" "substrateDop" "substrate")

;;-----
(display "  p-doping\n")
(sdedr:define-refeval-window "pDop" "Rectangle"  
  (position 0 0 0) 
  (position 0 contactFingerLength contactFingerLength))
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
(sdegeo:set-contact (find-region-id "nContact") "cathode")
(sdegeo:set-contact (find-region-id "pContact") "anode")

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-size "global" 
  refGlobalX  refGlobalY refGlobalZ 
  refGlobalX refGlobalY refGlobalZ )
(sdedr:define-refinement-region "global" "global" "substrate" )
;; on doping
(sdedr:define-refinement-size "doping" 
  substrateThickness deviceWidth deviceWidth  
  0.2 0.2 0.2 )
(sdedr:define-refinement-function "doping" "DopingConcentration" "MaxTransDiff" refDopingDiff)
(sdedr:define-refinement-region "doping" "doping" "substrate" )
;;optical refinement
(sdedr:define-refeval-window "optics" "Cuboid"
  (position 0 0 0)
  (position refOpticsDepth deviceWidth deviceWidth ))  
(sdedr:define-multibox-size "optics" 
  substrateThickness deviceWidth deviceWidth 
  refOpticsMin deviceWidth deviceWidth 
  refOpticsScale 1 1  )
(sdedr:define-multibox-placement "optics" "optics" "optics" )

(sdesnmesh:axisaligned
  "maxAspectRatio" 1e5
  "maxNeighborRatio" 1e6
  "smoothing" #f
)
;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "n@node@")

(display "Done.")
