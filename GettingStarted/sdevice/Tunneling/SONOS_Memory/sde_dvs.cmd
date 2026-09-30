;----------------------------------------------------------------------
;Define substrate doping level
;----------------------------------------------------------------------
(define DopSub "BoronActiveConcentration")
(define DopSD  "ArsenicActiveConcentration")
(define DopPoly  "PhosphorusActiveConcentration")
(define SubDop  5e17 )   ; [1/cm3]
(define HaloDop 1.5e18 ) ; [1/cm3]
;----------------------------------------------------------------------
; Setting parameters
; - lateral
(define Lg   0.13)               ; [um] Gate length
(define Lsp   0.1)                   ; [um] Spacer length
(define Lreox 0.007)                 ; [um] Reox Spacer length
(define Ltot (+ Lg (* 2 Lsp) 0.4) )  ; [um] Lateral extend total 

; - layers
(define Toxb 18e-4) ; [um] Gate bottom oxide thickness
#if "@struct@" == "1CTL"
(define Tsn  80e-4)  ; [um] Gate silicon nitride thickness
#elif "@struct@" == "2CTLs"
(define Tsn  178e-4)  ; [um] Gate silicon nitride thickness
#endif
(define Toxt 50e-4) ; [um] Gate top oxide thickness 
(define Hpol 50e-4) ; [um] Poly gate thickness
(define Hsub 0.6)   ; [um] Substrate thickness

;   - pn junction resolution
(define Gpn 0.002) ; [um]

(define YjHalo 0.07)  ; [um] Halo depth
(define YjExt  0.026) ; [um] Extension depth
(define YjSD   0.12)  ; [um] SD Junction depth

;----------------------------------------------------------------------
; Derived quantities
(define Ymax (/ Ltot 2.0))
(define Yg   (/ Lg   2.0))
(define Ysp  (+ Yg   Lsp))
(define Yrox (+ Yg   Lreox))

(define Xsub Hsub)
(define Xgoxb (* Toxb -1.0))
(define Xgsn  (* (+ Tsn Toxb)  -1.0))
(define Xgoxt (* (+ Toxt Tsn Toxb) -1.0))
(define Xpol (- Xgoxt Hpol))

(define Lcont (- Ymax Ysp))  
;----------------------------------------------------------------------
; Mesh quantities
(define DeltaThick @DeltaThick@)  ; Mesh refinement 
;----------------------------------------------------------------------
; Overlap resolution: New replaces Old
(sdegeo:set-default-boolean "ABA")
;----------------------------------------------------------------------
; Creating substrate region
(sdegeo:create-rectangle 
  (position    Xsub  0.0  0.0 ) 
  (position    0.0 Ymax 0.0 ) "Silicon" "R.Substrate" )

; Creating gate bottom oxide
(sdegeo:create-rectangle 
  (position    0.0 0.0  0.0 ) 
  (position    Xgoxb Ysp 0.0 ) 
  "Oxide" "R.Gateoxb"
)

; Creating gate silicon nitride
(sdegeo:create-rectangle 
  (position    Xgoxb  0.0 0.0 ) 
  (position    Xgsn Yg 0.0 ) 
  "@CTL@" "R.Gatesn"
)

#if "@struct@" == "2CTLs"
; Creating gate bottom oxide2
(sdegeo:create-rectangle 
  (position    (-  9.8e-3) 0.0  0.0 ) 
  (position    (- 11.6e-3) Ysp 0.0 ) 
  "Oxide" "R.Gateoxb2"
)
#endif

; Creating gate top oxide
(sdegeo:create-rectangle 
  (position    Xgsn  0.0 0.0 ) 
  (position    Xgoxt Yg 0.0 ) 
  "Oxide" "R.Gateoxt"
)

; Creating PolySi gate
(sdegeo:create-rectangle 
  (position    Xgoxt 0.0 0.0 ) 
  (position    Xpol Yg  0.0 ) 
  "PolySi" "R.Polygate"
)

; Creating PolyReox
(sdegeo:create-rectangle 
  (position    Xgoxb Yg    0.0 ) 
  (position    Xpol Ysp  0.0 ) 
  "Oxide" "R.PolyReox"
)

; Creating spacers regions
(sdegeo:create-rectangle 
  (position   (+ Xgoxb (- Yg Yrox))  Yrox   0.0 ) 
  (position   Xpol Ysp  0.0 ) 
  "Si3N4" "R.Spacer"
)

;----------------------------------------------------------------------
; Contact declarations
(sdegeo:define-contact-set "drain" 
  4.0  (color:rgb 0.0 1.0 0.0 ) "##")

(sdegeo:define-contact-set "gate" 
  4.0  (color:rgb 0.0 0.0 1.0 ) "##")

(sdegeo:define-contact-set "substrate"
  4.0  (color:rgb 0.0 1.0 1.0 ) "##")

;----------------------------------------------------------------------
; Separating lumps
(sde:separate-lumps)

; Setting region names
(sde:add-material 
  (find-body-id (position  (- Xsub 0.1) 5e-4  0.0)) 
  "Silicon" "R.Substrate")

(sde:add-material 
  (find-body-id (position  (* Toxb -0.5) 5e-4  0.0)) 
  "Oxide"    "R.Gateoxb")

#if "@struct@" == "1CTL"
(sde:add-material 
  (find-body-id (position  (+ Xgoxb (* Tsn -0.5)) 5e-4  0.0)) 
  "@CTL@"    "R.Gatesn")
  
(sde:add-material 
  (find-body-id (position  (+ Xgsn (* Toxt -0.5)) 5e-4  0.0)) 
  "Oxide"    "R.Gateoxt")
#elif "@struct@" == "2CTLs"
(sde:add-material 
  (find-body-id (position  -5e-3 5e-4  0.0)) 
  "@CTL@"    "R.Gatesn")


(sde:add-material 
  (find-body-id (position  -10e-3 5e-4  0.0)) 
  "Oxide"    "R.Gateoxb2")

(sde:add-material 
  (find-body-id (position  -16e-3 5e-4  0.0)) 
  "@CTL@"    "R.Gatesn2")
#endif

(sde:add-material 
  (find-body-id (position  (+ Xgsn (* Toxt -0.5)) 5e-4  0.0)) 
  "Oxide"    "R.Gateoxt")

(sde:add-material 
  (find-body-id (position  (+ Xgoxt (* Hpol -0.5))  5e-4  0.0)) 
  "PolySi"  "R.Polygate")

(sde:add-material 
  (find-body-id (position (- Xgoxb 0.01)  (* -0.5 (+ Ysp Yg)) 0.0)) 
  "Si3N4"   "R.Spacerleft")

(sde:add-material 
  (find-body-id (position (- Xgoxb 0.01)  (*  0.5 (+ Ysp Yg)) 0.0))  
  "Si3N4"   "R.Spacerright")

;----------------------------------------------------------------------
; Contact settingssde
(sdegeo:define-2d-contact 
 (find-edge-id (position 0.0 (* (+ Ymax Ysp)  0.5) 0.0))
 "drain")

(sdegeo:define-2d-contact 
 (find-edge-id (position Xpol 5e-4  0.0))
 "gate")

(sdegeo:define-2d-contact 
 (find-edge-id (position Xsub 5e-4  0.0))
 "substrate")

;----------------------------------------------------------------------
; Saving BND file
(sdeio:save-tdr-bnd (get-body-list) "n@node@_half_bnd.tdr")
;----------------------------------------------------------------------
; Profiles:
; - Substrate
(sdedr:define-constant-profile "Const.Substrate" 
 DopSub SubDop )
(sdedr:define-constant-profile-region  "PlaceCD.Substrate" 
 "Const.Substrate" "R.Substrate" )

; - Poly
(sdedr:define-constant-profile "Const.Gate" 
 DopPoly 1e20 )
(sdedr:define-constant-profile-region "PlaceCD.Gate" 
 "Const.Gate" "R.Polygate" )

; - Source/Drain extensions 
; -- base line definitions
(sdedr:define-refeval-window "BaseLine.Ext" "Line"  
 (position 0.0  Yrox  0.0)  
 (position 0.0  Ymax  0.0) )

;   implant definition
(sdedr:define-gaussian-profile "Impl.Extprof"
 DopSD
 "PeakPos" 0  "PeakVal" 1e19
 "ValueAtDepth" SubDop "Depth" YjExt
 "Gauss"  "Factor" 0.8
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.Ext" 
 "Impl.Extprof" "BaseLine.Ext" "Negative" "NoReplace" "Eval")

; - Source/Drain implants
; -- base line definitions
(sdedr:define-refeval-window "BaseLine.SD" "Line"  
 (position 0.0 Ysp 0.0)  
 (position 0.0 (* Ymax 2.0) 0.0) )
; -- implant definition
(sdedr:define-gaussian-profile "Impl.SDprof"
 DopSD 
 "PeakPos" 0  "PeakVal" 1e20
 "ValueAtDepth" SubDop "Depth" YjSD
 "Gauss"  "Factor" 0.8
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.SD" 
 "Impl.SDprof" "BaseLine.SD" "Negative" "NoReplace" "Eval")

;----------------------------------------------------------------------
;Place sub-meshes
;----------------------------------------------------------------------
(sdedr:define-refeval-window "Pl.global" "Rectangle" 
	(position (- Xpol 0.1) -0.1 0.0)  
	(position (+ Xsub 0.1) (+ Ymax 0.1) 0.0)
) 
;(sdedr:define-submesh "SubMesh" "n@node@_tif.tdr" 'w)
;(sdedr:define-submesh-placement "SubMesh_R" "SubMesh" 
;	"Pl.global" "Replace"
;	"AttachPoint" (position 0 0 0) "ToPoint" (position 0 0 0)
;)
;----------------------------------------------------------------------
;Meshing
;----------------------------------------------------------------------

;- Silicon
(sdedr:define-refinement-size "R.global" (/ (- Xsub Xpol) 16) (/ Ymax 4) 0.005 0.005)
(sdedr:define-refinement-placement "R.global" "R.global" "Pl.global")
(sdedr:define-refinement-function "R.global" "DopingConcentration" "MaxTransDiff" 1)

#if "@struct@" == "2CTLs"
(sdedr:define-refinement-function  "R.global" 
  "MaxLenInt" "Oxide" "@CTL@" 0.5e-3 2 "DoubleSide")
#endif

;- Device area
(sdedr:define-refeval-window "R.device" "Rectangle"  (position 0.0 0.0 0.0) (position 0.3 Ymax 0.0))
(sdedr:define-refinement-size "R.device" 0.025 (/ Ymax 8) 0.01 0.01)
(sdedr:define-refinement-placement "R.device" "R.device" "R.device")

;- Channel
(sdedr:define-refeval-window "MB.channel" "Rectangle"  (position 0.0 0.0 0.0) (position  0.2  (* +0.5 Lg)0.0))
(sdedr:define-multibox-size "MB.channel" 1 (/ Lg 10) 0.0004 66  1.5    1)
(sdedr:define-multibox-placement "MB.channel" "MB.channel" "MB.channel")

;- PolySi Gate
(sdedr:define-refeval-window "MB.poly" "Rectangle"  (position Xgoxt 0.0 0.0) (position Xpol (* +0.5 Lg)  0.0))
(sdedr:define-multibox-size "MB.poly" 1 (/ Lg 10) 0.0004 66 -1.5 1 )
(sdedr:define-multibox-placement "MB.poly" "MB.poly" "MB.poly")


(sdesnmesh:axisaligned "xCuts" 
   (list
    9.7e-3 9.8e-3 9.9e-3 13.7e-3 13.8e-3 13.9e-3
    (+ 0 (* 1.00 DeltaThick)) 
    (+ 0 (* 0.75 DeltaThick)) 
    (+ 0 (* 0.50 DeltaThick)) 
    (+ 0 (* 0.25 DeltaThick)) 
       0 
    (- 0 (* 0.25 DeltaThick)) 
    (- 0 (* 0.50 DeltaThick)) 
    (- 0 (* 0.75 DeltaThick)) 
    (- 0 (* 1.00 DeltaThick))
    (- 0 (* 1.25 DeltaThick)) 
    (- 0 (* 1.50 DeltaThick))  

    (+ Xgoxb (* 1.00 DeltaThick)) 
    (+ Xgoxb (* 0.75 DeltaThick)) 
    (+ Xgoxb (* 0.50 DeltaThick)) 
    (+ Xgoxb (* 0.25 DeltaThick)) 
       Xgoxb 
    (- Xgoxb (* 0.25 DeltaThick)) 
    (- Xgoxb (* 0.50 DeltaThick)) 
    (- Xgoxb (* 0.75 DeltaThick)) 
    (- Xgoxb (* 1.00 DeltaThick))
    (- Xgoxb (* 1.25 DeltaThick)) 
    (- Xgoxb (* 1.50 DeltaThick)) 
 
    (+ Xgsn (* 1.50 DeltaThick)) 
    (+ Xgsn (* 1.25 DeltaThick)) 
    (+ Xgsn (* 1.00 DeltaThick)) 
    (+ Xgsn (* 0.75 DeltaThick)) 
    (+ Xgsn (* 0.50 DeltaThick)) 
    (+ Xgsn (* 0.25 DeltaThick)) 
       Xgsn 
    (- Xgsn (* 0.25 DeltaThick)) 
    (- Xgsn (* 0.50 DeltaThick)) 
    (- Xgsn (* 0.75 DeltaThick)) 
    (- Xgsn (* 1.00 DeltaThick))

    (+ Xgoxt (* 1.50 DeltaThick)) 
    (+ Xgoxt (* 1.25 DeltaThick)) 
    (+ Xgoxt (* 1.00 DeltaThick)) 
    (+ Xgoxt (* 0.75 DeltaThick)) 
    (+ Xgoxt (* 0.50 DeltaThick)) 
    (+ Xgoxt (* 0.25 DeltaThick)) 
       Xgoxt 
    (- Xgoxt (* 0.25 DeltaThick)) 
    (- Xgoxt (* 0.50 DeltaThick)) 
    (- Xgoxt (* 0.75 DeltaThick)) 
    (- Xgoxt (* 1.00 DeltaThick))

   )  
)

;----------------------------------------------------------------------

; Build Mesh 
(sde:build-mesh "n@node@_half_msh")

;----------------------------------------------------------------------
; Reflect device
(system:command "tdx -mtt -y -ren drain=source n@node@_half_msh n@node@_msh")
;----------------------------------------------------------------------


