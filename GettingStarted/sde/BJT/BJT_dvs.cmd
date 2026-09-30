; Reinitializing SDE 
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "-x")

; Emulation Domain
(define Ymax 2.2) ; Width
(define Zmax 1.2) ; Depth
(sdepe:define-pe-domain (list 0.0 0.0 Ymax Zmax))

; Substrate definition
(define Nasub 1e16)  ; Boron concentration
(define Xsub 2.0)    ; Initial Substrate Height
(sdepe:add-substrate "material" "Silicon" "thickness" Xsub "region" "Substrate")
(sdepe:doping-constant-placement "DopSub" 
 "BoronActiveConcentration" Nasub "Substrate")

; Subcollector implant mask
(define Yb1 0.2)  ; Beginning of base window
(define Yb2 1.2)  ; End of base window
(define Yc1 1.5)  ; Beginning of collector contact window
(define Yc2 2.0)  ; End of collector contact window
(define Zc  0.8)  ; Depth of contact

(sdepe:generate-mask "SUBC" (list (list Yb1 0.0 Yc2 Zc)) )

(define Tre 0.5)
(sdepe:pattern "mask" "SUBC" "polarity" "dark" "type" "aniso"
               "material" "Resist"  "thickness" Tre )

; Subcollector implant
(define LatDiff 0.02)
(sdedr:define-gaussian-profile 
	"SubCol" "PhosphorusActiveConcentration" 
	"PeakPos" 0.0 "PeakVal" 5e+19 
	"ValueAtDepth" Nasub "Depth" 0.5 
	"Gauss" "Length" LatDiff)

(sdepe:implant "SubCol")
(sdepe:remove "material" "Resist")

; Deposit Silicon epi layer
(define Tepi 0.3)
(define Ndepi 5e16)
(define SiEpi (sdepe:depo "material" "Silicon"  "thickness" Tepi "type" "iso"))
(sde:add-material SiEpi "Silicon" "SiEpi")
(sdepe:doping-constant-placement "DopEpi" "ArsenicActiveConcentration" 
  Ndepi "SiEpi")

; Isolation mask
(sdepe:generate-mask "ISO" ; Protection mask
(list (list Yb1 0.0 Yb2 Zc)
      (list Yc1 0.0 Yc2 Zc) ))
(sdepe:pattern "mask" "ISO" "polarity" "light" "type" "aniso"
               "material" "Resist"  "thickness" Tre )
(sdepe:etch-material "material" "Silicon" "depth" Tepi ) ; Trench etching
(sdepe:remove "material" "Resist")

; Fill trench
(define Xtop (sde:min-x (get-body-list)))
(sdepe:fill-device "material" "Oxide" "height" (- Xtop 0.1) )

; CMP polish 
(sdepe:polish-device "thickness" 0.1)

; Deposit screening oxide
(define Tscreen 0.03)
(sdepe:depo "material" "Oxide" "thickness" Tscreen)

; Collector contact implant mask
(sdepe:generate-mask "COL" (list (list Yc1 0.0 Yc2 Zc)))
(sdepe:pattern "mask" "COL" "polarity" "dark" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Collector contact implant
(sdedr:define-gaussian-profile "ColCont" "ArsenicActiveConcentration" 
	"PeakPos" 0.0 "PeakVal" 5e+19 
	"ValueAtDepth" 1e+17 "Depth" 0.5 
	"Gauss" "Length" LatDiff
)
(sdepe:implant "ColCont")
(sdepe:remove "material" "Resist")

; Base implant mask
(sdepe:generate-mask "BAS" (list (list Yb1 0.0 Yb2 Zc)))
(sdepe:pattern "mask" "BAS" "polarity" "dark" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Base implant
(define Tbase 0.2)
(define Nabase 3e18)
(sdedr:define-gaussian-profile 
	"Base" "BoronActiveConcentration" 
	"PeakPos" 0.0 "PeakVal" Nabase 
	"ValueAtDepth" Ndepi "Depth" Tbase 
	"Gauss" "Length" LatDiff
)
(sdepe:implant "Base")
(sdepe:remove "material" "Resist")

; Emitter implant mask
(define Ye1 0.9)
(define Ye2 1.1)
(define Ze  (* 0.7 Zc))
(sdepe:generate-mask "EMIT" (list  (list Ye1 0.0 Ye2 Ze)))
(sdepe:pattern "mask" "EMIT" "polarity" "dark" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Emitter implant
(define Temit 0.1)
(sdedr:define-gaussian-profile 
	"Emitter" "PhosphorusActiveConcentration" 
	"PeakPos" 0.0 "PeakVal" 1e+20 
	"ValueAtDepth" 1.0e18 "Depth" Temit 
	"Gauss" "Length" LatDiff
)
(sdepe:implant "Emitter")
(sdepe:remove "material" "Resist")

; Emitter and collector contact holes mask
(define reset 0.05)
(sdepe:generate-mask "PCH" 
 (list (list (+ Ye1 reset) 0.0 (- Ye2 reset) (- Ze reset))
       (list (+ Yc1 reset) 0.0 (- Yc2 reset) (- Zc reset)))) 
(sdepe:pattern "mask" "PCH" "polarity" "dark" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Etching emitter and collector contact holes
(sdepe:etch-material "material" "Oxide" "depth" Tscreen)
(sdepe:remove "material" "Resist")

; Deposit PolySi
(define Tpoly 0.1)
(define POLYSI (sdepe:depo "material" "PolySi" "thickness" Tpoly))
(sde:add-material POLYSI "PolySi" "Poly")
(sdepe:doping-constant-placement "DopPoly" "ArsenicActiveConcentration" 1e20 
  "Poly")

; Poly mask
(sdepe:generate-mask "POL"  (list  (list Yc1 0.0 Yc2 Zc) (list Ye1 0.0 Ye2 Ze)))
(sdepe:pattern "mask" "POL"  "polarity" "light" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Etching poly
(sdepe:etch-material "material" "PolySi" "depth" Tpoly)
(sdepe:remove "material" "Resist")

; Fill
(define Xtop (- (sde:min-x (get-body-list)) 0.05))
(sdepe:fill-device "material" "Oxide" "height" Xtop )

; Metal contact holes mask
(define Ybc1 (+ Yb1 0.1))
(define Ybc2 (+ Ybc1 0.4))
(sdepe:generate-mask "MET1" 
 (list (list Yc1  0.0 Yc2  Zc)
       (list Ye1  0.0 Ye2  Ze)
       (list Ybc1 0.0 Ybc2 Ze))) 
(sdepe:pattern "mask" "MET1" "polarity" "dark" "type" "aniso"
               "material" "Resist" "thickness" Tre)

; Etching metal contact holes
(sdepe:etch-material "material" "Oxide" "depth" (+ Tpoly 0.05))
(sdepe:etch-material "material" "Oxide" "depth" Tscreen)
(sdepe:remove "material" "Resist")

;----------------------------------------------------------------------
; Fill contact holes
(sdepe:fill-device "material" "Metal")

(sde:separate-lumps)
;----------------------------------------------------------------------
; Contact definitions 
(sdegeo:set-contact (find-face-id (position 0.0 0.01 0.01)) "substrate")  

(define BCID (find-body-id 
  (position  (+ Xtop 0.01) (* 0.5 (+ Ybc1 Ybc2)) (* 0.5 Ze))))                  
(sdegeo:set-contact BCID "base" "remove")  

(define ECID (find-body-id 
  (position (+ Xtop 0.01) (* 0.5 (+ Ye1 Ye2)) (* 0.5 Ze))))                  
(sdegeo:set-contact ECID "emitter" "remove")  

(define CCID (find-body-id 
  (position (+ Xtop 0.01) (* 0.5 (+ Yc1 Yc2)) (* 0.5 Zc))))                  
(sdegeo:set-contact CCID "collector" "remove")  
;-----------------------------------------------------------------------               

;----------------------------------------------------------
; Meshing
;---------------------------------------------------
; Global
(define Xbot (sde:max-x (get-body-list)))
(define Xtop (sde:min-x (get-body-list)))
(sdedr:define-refeval-window "All_RW" "Cuboid" 
  (position  Xtop 0 0) (position Xbot Ymax Zmax) )
(sdedr:define-refinement-size "All_RD" 
  (/ (- Xbot Xtop) 08.0) (/ Ymax  8.0) (/ Zmax  8.0)
  (/ (- Xbot Xtop) 16.0) (/ Ymax 16.0) (/ Zmax 16.0))
(sdedr:define-refinement-function "All_RD" 
  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "All_PL" "All_RD" "All_RW" )

; Top region
(sdedr:define-refeval-window "Top_RW" "Cuboid" 
  (position -2.3 Yb1 0) (position -1.25 Yc2 Zc))
(sdedr:define-refinement-size "Top_RD" 
  (/ (- Xbot Xtop) 16.0) (/ Ymax 16.0) (/ Zmax 16.0)
  (/ (- Xbot Xtop) 32.0) (/ Ymax 32.0) (/ Zmax 32.0))
(sdedr:define-refinement-function "Top_RD" 
  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "Top_PL" "Top_RD" "Top_RW" )

; Base region
(sdedr:define-refeval-window "Base_RW" "Cuboid" 
  (position (- (- Xsub) Tepi) Yb1 0.0) (position (- Xsub) Yb2 Zc ))
(sdedr:define-refinement-size "Base_RD" 
  (/ Tepi 8.0) (/ (+ Yb2 Yb1)  8.0) (/ Zc  8.0)
  (/ Tepi 32.0) (/ (+ Yb2 Yb1) 32.0) (/ Zc 32.0))
(sdedr:define-refinement-function "Base_RD" 
  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "Base_PL" "Base_RD" "Base_RW" )

; Active region
(sdedr:define-refeval-window "Active_RW" "Cuboid" 
  (position -2.3 0.85 0.0) (position -2.15 1.15 0.6))
(sdedr:define-refinement-size "Active_RD" 
  0.02 0.02 0.08
  0.01 0.01 0.04)
(sdedr:define-refinement-function "Active_RD" 
  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "Active_PL" "Active_RD" "Active_RW" )

; Poly
(sdedr:define-refinement-size "Poly_RD" 
  (/ Tpoly 8.0) 99 99 
  (/ Tpoly 9.0) 66 66
)
(sdedr:define-refinement-material "Poly_PL" "Poly_RD" "PolySi" ) 

;----------------------------------------------------------
; Meshing the device
;---------------------------------------------------
(sde:build-mesh "n@node@")




