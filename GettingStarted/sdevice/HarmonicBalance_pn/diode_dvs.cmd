(sde:clear)

(define tiny 1e-5)

(define R_sub 10)
(define h_sub  3)

(define R_epi 10)
(define h_epi  7)

(define r_iso  5)
(define R_iso  R_epi)
(define h_iso  0.5)

(define R_cathode (+ r_iso 2.0))

(define x_epi 0)
(define X_epi (+ x_epi h_epi))

(define x_sub X_epi)
(define X_sub (+ x_sub h_sub))

(define X_iso x_epi)
(define x_iso (- X_iso h_iso))

; define Regions ---------------------------------------------------------------
(sdegeo:create-rectangle (position  x_iso r_iso  0)  (position X_iso R_iso 0) "Oxide"   "isol")
(sdegeo:create-rectangle (position  x_epi 0      0)  (position X_epi R_epi 0) "Silicon" "epi" )
(sdegeo:create-rectangle (position  x_sub 0      0)  (position X_sub R_sub 0) "Silicon" "sub" )

; define Contacts --------------------------------------------------------------
(sdegeo:set-contact (find-edge-id (position X_sub tiny 0)) "anode" )
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle 
	(position (- x_iso tiny) 0         0)  
	(position x_epi          R_cathode 0) 
	"Aluminum" "cathode_metal"
)
(sdegeo:set-contact (find-region-id "cathode_metal") "cathode")
(sdegeo:delete-region (find-region-id "cathode_metal"))


; define Eval windows ------------------------------------------------ 
(sdedr:define-refeval-window "REW_ncont"  "Line"  (position 0 -1 0) (position 0 r_iso 0))


; Doping Profiles ----------------------------------------------------
; Substrate
(sdedr:define-constant-profile        "CPD_sub" "BoronActiveConcentration" 5e18)
(sdedr:define-constant-profile-region "CPP_sub" "CPD_sub" "sub" 0.5 "Gauss")
; Epi
(sdedr:define-constant-profile "CPD_epi" "BoronActiveConcentration" 1e14)
(sdedr:define-constant-profile-region "CPP_epi" "CPD_epi" "epi")

; n-Contact Profile
(sdedr:define-analytical-profile-placement "APP_ncont" "APD_ncont" "REW_ncont" "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "APD_ncont" "ArsenicActiveConcentration" "PeakPos" 0  "PeakVal" 1e+20 "Length" 0.2 "Gauss"  "Factor" 1)

; Mesh refinements ---------------------------------------------------
(sdedr:define-refeval-window       "REW_g" "Rectangle"  (position x_iso 0 0) (position X_sub R_sub 0))
(sdedr:define-refinement-size      "RED_g" 0.5 1.0 0.01 0.01 )
(sdedr:define-refinement-placement "REP_g" "RED_g" (list "window" "REW_g" ) )
(sdedr:define-refinement-function  "RED_g" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function  "RED_g" "MaxLenInt" "epi" "sub"      0.10 1.4 "UseRegionNames")
(sdedr:define-refinement-function  "RED_g" "MaxLenInt" "epi" "isol"     0.01 1.7 "UseRegionNames")
(sdedr:define-refinement-function  "RED_g" "MaxLenInt" "epi" "cathode"  0.01 1.7 "UseRegionNames")


; Mesh the device ---------------------------------------------------
(sdesnmesh:axisaligned "fitInterfaces" #t)
(sde:build-mesh "n@node@_msh")

