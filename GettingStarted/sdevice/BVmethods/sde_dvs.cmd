;----------------------------------------------------------------------
(sde:clear)
; Setting parameters
; - lateral
(define Lg   0.13)                  ; [um] Gate length
(define Lsp   0.1)                  ; [um] Spacer length
(define Lreox 0.01)                 ; [um] Spacer length
(define Ltot (+ Lg (* 2 Lsp) 0.8) ) ; [um] Lateral extend total 

; - layers
(define Hsub 1.0)   ; [um] Substrate thickness
(define Tox  20e-4) ; [um] Gate oxide thickness
(define Hpol 0.2)   ; [um] Poly gate thickness

; - other
;   - spacer rounding
(define fillet-radius 0.08) ; [um] Rounding radius

;   - pn junction resolution
(define Gpn 0.002) ; [um]

;   - Substrate doping level
(define SubDop 1e18 ) ; [1/cm3]

(define Xj  0.1 ) ; [um] Junction depth

;----------------------------------------------------------------------
; Derived quantities
(define Ymax (/ Ltot 2.0))
(define Yg   (/ Lg   2.0))
(define Ysp  (+ Yg   Lsp))

(define Xsub Hsub)
(define Xgox (* Tox -1.0))
(define Xpol (- Xgox Hpol))

(define Lcont (- Ymax Ysp))  

;----------------------------------------------------------------------
; Creating substrate region
(sdegeo:create-rectangle 
	(position    Xsub 0.0 0.0 ) 
	(position    0.0 Ymax 0.0 ) 
	"Silicon" "R.Substrate" 
)

; Creating gate oxide
(sdegeo:create-rectangle 
	(position    0.0 0.0  0.0 ) 
	(position    Xgox Ysp 0.0 ) 
	"Oxide" "R.Gateox"
)

; Creating PolyReox
(sdegeo:create-rectangle 
  (position    Xgox 0.0  0.0 ) 
  (position    Xpol Ysp  0.0 ) 
  "Oxide" "R.PolyReox"
)

; Creating spacers regions
(sdegeo:create-rectangle 
	(position   Xgox (+ Yg Lreox)  0.0 ) 
	(position   Xpol Ysp  0.0 ) 
	"Nitride" "R.Spacer"
)

; Creating PolySi gate
(sdegeo:create-rectangle 
	(position    Xgox 0.0 0.0 ) 
	(position    Xpol Yg  0.0 ) 
	"PolySilicon" "R.Polygate"
)

;----------------------------------------------------------------------
; - rounding spacer
(sdegeo:fillet-2d 
	(find-vertex-id (position Xpol Ysp 0.0 ))
	fillet-radius
)

;----------------------------------------------------------------------
; Contacts
(sdegeo:set-contact	(find-edge-id (position 0.0 (* (+ Ymax Ysp)  0.5) 0.0))	"drain")
(sdegeo:set-contact (find-body-id (position -0.1 5e-4 0.0)) "gate" "remove")
(sdegeo:set-contact (find-edge-id (position Xsub 5e-4  0.0)) "substrate")
 
;----------------------------------------------------------------------
; Profiles:
; - Substrate
(sdedr:define-constant-profile "Def.Substrate" "BoronActiveConcentration" SubDop )
(sdedr:define-constant-profile-region  "Pl.Substrate" "Def.Substrate" "R.Substrate" )

; - Poly
(sdedr:define-constant-profile "Def.Gate" "ArsenicActiveConcentration" 1e20 )
(sdedr:define-constant-profile-region "Pl.Gate" "Def.Gate" "R.Polygate" )

; Source/Drain base line definitions
(sdedr:define-refeval-window 
	"Base.Drain" "Line"  
	(position 0.0 Ysp 0.0)  
	(position 0.0 (* Ymax 2.0) 0.0) 
)
; Source/Drain implant definition
(sdedr:define-gaussian-profile "Def.Drain"
	"ArsenicActiveConcentration" 
	"PeakPos" 0  "PeakVal" 5e20
	"ValueAtDepth" SubDop "Depth" Xj
	"Erf"  "Factor" 0.4
)
; Source/Drain implants
(sdedr:define-analytical-profile-placement 
	"Pl.Drain" "Def.Drain" "Base.Drain" 
	"Both" "NoReplace" "Eval"
)

; Source/Drain extensions base line definitions
(sdedr:define-refeval-window 
	"Base.DrainExt" "Line"  
	(position 0.0    Yg        0.0)  
	(position 0.0 (* Ymax 2.0) 0.0) 
)
; Source/Drain extentions implant definition
(sdedr:define-gaussian-profile "Def.DrainExt"
	"ArsenicActiveConcentration"
	"PeakPos" 0  "PeakVal" 1e19
	"ValueAtDepth" SubDop "Depth" (* Xj 0.5)
	"Erf"  "Factor" 0.8
)
; Source/Drain implants
(sdedr:define-analytical-profile-placement 
	"Pl.DrainExt" "Def.DrainExt" "Base.DrainExt" 
	"Both" "NoReplace" "Eval"
)

;----------------------------------------------------------------------
; Meshing Strategy:

; Substrate
(sdedr:define-refinement-size "Ref.Sub" 
	(/ Hsub 8.0)  (/ Ltot 4.0) 
	Gpn            Gpn 
)
(sdedr:define-refinement-function "Ref.Sub" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-region "Pl.Sub" "Ref.Sub" "R.Substrate")

; Active
(sdedr:define-refeval-window "Win.Act" 
	"Rectangle"  
	(position   0.0  0.0   0.0) 
	(position  (* Xj  1.8) Ymax    0.0)
)
(sdedr:define-refinement-size "Ref.Act" 
	(/ Xj 4.0) (/ Lcont 4.0) 
	Gpn            Gpn
)
(sdedr:define-refinement-function "Ref.Act" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "Pl.Act" "Ref.Act" "Win.Act" )

; Channel
(sdedr:define-refeval-window "Win.Channel" 
	"Rectangle"  
	(position   0.0  0.0   0.0) 
	(position  (* Xj  1.8) (+ Yg (* 2.0 Lreox))    0.0)
)
(sdedr:define-refinement-size "Ref.Channel" 
	(/ Xj 4.0) (/ Lcont 4.0) 
	Gpn            Gpn 
)
(sdedr:define-refinement-function "Ref.Channel" "DopingConcentration" "MaxTransDiff" 0.8)
(sdedr:define-refinement-function "Ref.Channel" "MaxLenInt" "Silicon" "Oxide" 0.0005 1.3 "DoubleSide")
(sdedr:define-refinement-placement "Pl.Channel" "Ref.Channel" "Win.Channel" )

; Gate oxide
(sdedr:define-refinement-size "Ref.GOX" 
	(/ Tox 4.0)  (/ Ltot 4.0) 
	(/ Tox 8.0)   Gpn         )
(sdedr:define-refinement-region "Pl.GOX" "Ref.GOX" "R.Gateox" )

(sdesnmesh:axisaligned "xCuts" (list 0.0 Xgox))
;----------------------------------------------------------------------
; Build Mesh
(sde:build-mesh "" "n@node@_half_msh")

;----------------------------------------------------------------------
; Reflect the device
(system:command "tdx -mtt -y -ren drain=source n@node@_half_msh  n@node@_msh")
