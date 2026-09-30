(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

(if (string=? "@Type@" "nMOS") 
 (begin
  (define DopSub "BoronActiveConcentration")
  (define DopSD  "ArsenicActiveConcentration")
;   - Substrate doping level
  (define SubDop  5e17 )   ; [1/cm3]
  (define HaloDop 1.5e18 ) ; [1/cm3]
 )
 (begin 
  (define DopSub "ArsenicActiveConcentration")
  (define DopSD  "BoronActiveConcentration")
;   - Substrate doping level
  (define SubDop  5e17 )   ; [1/cm3]
  (define HaloDop 1.0e18 ) ; [1/cm3]
 )
)
;----------------------------------------------------------------------
; Setting parameters
; - lateral
(define Lg    @lgate@)               ; [um] Gate length
(define Lsp   0.1)                   ; [um] Spacer length
(define Lreox 0.007)                 ; [um] Reox Spacer length
(define Ltot (+ Lg (* 2 Lsp) 0.4) )  ; [um] Lateral extend total 

; - layers
(define Hsub 1.0)   ; [um] Substrate thickness
(define Tox  10e-4) ; [um] Gate oxide thickness
(define Thk  20e-4) ; [um] Gate oxide thickness
(define Hpol 0.2)   ; [um] Poly gate thickness

; - other
;   - spacer rounding
(define fillet-radius 0.08) ; [um] Rounding radius

;   - pn junction resolution
(define Gpn 0.002) ; [um]

(define XjHalo 0.07)  ; [um] Halo depth
(define XjExt  0.026) ; [um] Extension depth
(define XjSD   0.12)  ; [um] SD Junction depth

;----------------------------------------------------------------------
; Derived quantities
(define Xmax (/ Ltot 2.0))
(define Xg   (/ Lg   2.0))
(define Xsp  (+ Xg   Lsp))
(define Xrox (+ Xg   Lreox))

(define Ysub Hsub)
(define Ygox (* Tox -1.0))
(define Yghk (- Ygox Thk))
(define Ypol (- Yghk Hpol))

(define Lcont (- Xmax Xsp))  

;----------------------------------------------------------------------
; coordinates for reference window to define stress in Silicon
(define XminSt   (- Xmax) )
(define XmaxSt      Xmax  )
(define YminSt      Ypol  )
(define YmaxSt      Ysub  )
;----------------------------------------------------------------------
; Overlap resolution: New replaces Old
(sdegeo:set-default-boolean "ABA")

;----------------------------------------------------------------------
; Creating substrate region
(sdegeo:create-rectangle 
  (position    0.0  Ysub  0.0 ) 
  (position    Xmax 0.0 0.0 ) 
  "Silicon" "R.Substrate" 
)

; Creating gate oxide
(sdegeo:create-rectangle 
  (position    0.0 0.0  0.0 ) 
  (position    Xsp Ygox 0.0 ) 
  "Oxide" "R.Gateox"
)

; Creating PolyReox
(sdegeo:create-rectangle 
  (position    0.0  Ygox 0.0 ) 
  (position    Xsp  Ypol 0.0 ) 
  "Oxide" "R.PolyReox"
)

; Creating spacers regions
(sdegeo:create-rectangle 
  (position   (+ Xg Lreox)  Ygox 0.0 ) 
  (position    Xsp  Ypol 0.0 ) 
  "Nitride" "R.Spacer"
)

; Creating gate hk
(sdegeo:create-rectangle 
  (position    0.0 Ygox  0.0 ) 
  (position    Xg Yghk 0.0 ) 
  "HfO2" "R.Gatehk"
)


; Creating PolySi gate
(sdegeo:create-rectangle 
  (position    0.0 Yghk 0.0 ) 
  (position    Xg  Ypol 0.0 ) 
  "PolySilicon" "R.Polygate"
)

;----------------------------------------------------------------------
; - rounding spacer
(sdegeo:fillet-2d 
 (find-vertex-id (position Xsp Ypol 0.0 ))
 fillet-radius)


;----------------------------------------------------------------------
; Set Contacts (Source will be created when reflecting the structure)
(sdegeo:set-contact (find-edge-id (position (* (+ Xmax Xsp)  0.5) 0.0 0.0)) "drain")
(sdegeo:set-contact (find-edge-id (position 5e-4 Ypol 0.0)) "gate")
(sdegeo:set-contact (find-edge-id (position 5e-4  Ysub 0.0)) "substrate")
 
;----------------------------------------------------------------------

; Profiles:
; - Substrate
(sdedr:define-constant-profile "Const.Substrate" 
 DopSub SubDop )
(sdedr:define-constant-profile-region  "PlaceCD.Substrate" 
 "Const.Substrate" "R.Substrate" )

; - Poly
(sdedr:define-constant-profile "Const.Gate" 
 DopSD 1e20 )
(sdedr:define-constant-profile-region "PlaceCD.Gate" 
 "Const.Gate" "R.Polygate" )

; - Halo 
; -- base line definitions
(sdedr:define-refeval-window "BaseLine.Halo" "Line"  
 (position    Xg        0.0 0.0)  
 (position (* Xmax 2.0) 0.0 0.0) )
; -- implant definition
(sdedr:define-gaussian-profile "Impl.Haloprof"
 DopSub
 "PeakPos" 0  "PeakVal" HaloDop
 "ValueAtDepth" (* 0.1 HaloDop)  "Depth" XjHalo
 "Gauss"  "Factor" 1.0
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.Halo" 
 "Impl.Haloprof" "BaseLine.Halo" "Positive" "NoReplace" "Eval")

; - Source/Drain extensions 
; -- base line definitions
(sdedr:define-refeval-window "BaseLine.Ext" "Line"  
 (position    Xrox      0.0 0.0)  
 (position (* Xmax 2.0) 0.0 0.0) )
;   implant definition
(sdedr:define-gaussian-profile "Impl.Extprof"
 DopSD
 "PeakPos" 0  "PeakVal" 1e19
 "ValueAtDepth" SubDop "Depth" XjExt
 "Gauss"  "Factor" 0.8
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.Ext" 
 "Impl.Extprof" "BaseLine.Ext" "Positive" "NoReplace" "Eval")

; - Source/Drain implants
; -- base line definitions
(sdedr:define-refeval-window "BaseLine.SD" "Line"  
 (position Xsp 0.0 0.0)  
 (position (* Xmax 2.0) 0.0 0.0) )
; -- implant definition
(sdedr:define-gaussian-profile "Impl.SDprof"
 DopSD 
 "PeakPos" 0  "PeakVal" 1e20
 "ValueAtDepth" SubDop "Depth" XjSD
 "Gauss"  "Factor" 0.8
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.SD" 
 "Impl.SDprof" "BaseLine.SD" "Positive" "NoReplace" "Eval")


(sdedr:define-refeval-window "REW_strain" "Rectangle"  
  (position XminSt YminSt 0) (position XmaxSt YmaxSt 0))
(sdedr:define-analytical-profile-placement "APP_strain" "APD_strain" "REW_strain" 
  "Positive" "NoReplace" "Eval" "Silicon" 0 "material")
(sdedr:define-gaussian-profile "APD_strain" "StressXX" 
  "PeakPos" 0  "PeakVal" @stress@ "StdDev" 0.1 "Gauss"  "Factor" 1.0)

;----------------------------------------------------------------------
; Meshing Strategy:
; Substrate
(sdedr:define-refinement-size "Ref.Substrate" 
  (/ Xmax 4.0)  (/ Hsub 8.0) 
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.Substrate" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function "Ref.Substrate" 
 "MaxLenInt" "Silicon" "Oxide" 0.001 2)
(sdedr:define-refinement-region "RefPlace.Substrate" 
 "Ref.Substrate" "R.Substrate" )

; Active
(sdedr:define-refeval-window "RWin.Act" 
 "Rectangle"  
 (position   0.0  0.0   0.0) 
 (position  Xmax (* XjSD  1.5)    0.0) )
(sdedr:define-refinement-size "Ref.SiAct" 
  (/ Lcont 4.0) (/ XjSD 6.0) 
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.SiAct" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "RefPlace.SiAct" 
 "Ref.SiAct" "RWin.Act" )

; Channel & Gate Oxides
(sdedr:define-refeval-window "RWin.Cha" 
 "Rectangle"  
 (position   0.0  Ygox   0.0) 
 (position   Xrox XjSD   0.0) )
(sdedr:define-refinement-size "Ref.Cha" 
  (/ Lcont 12.0) (/ XjSD 6.0) 
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.Cha" "MaxLenInt" "Silicon" "Oxide"   0.0002 2 "DoubleSide" )
(sdedr:define-refinement-placement "RefPlace.Cha" 
 "Ref.Cha" "RWin.Cha" )

; vertical mesh size hk dielectric
(sdedr:define-refinement-size "RED_b" 0.01 0.0005 0 0.001 0.0005 0 )
(sdedr:define-refinement-material "REP_b" "RED_b" "HfO2" )

; Poly Interfaces
(sdedr:define-refinement-size "RED_c" 0.01 0.01 0 0.001 0.001 0 )
(sdedr:define-refinement-material "REP_c" "RED_c" "PolySi" )
(sdedr:define-refinement-function "RED_c" "MaxLenInt" "PolySi" "Oxide" 0.001 2)
(sdedr:define-refinement-function "RED_c" "MaxLenInt" "PolySi" "HfO2" 0.001 2)

;----------------------------------------------------------------------
; Build Mesh 
(sde:build-mesh "n@node@_half_msh")

;----------------------------------------------------------------------
; Reflect device

(system:command "tdx -mtt -x -ren drain=source n@node@_half_msh n@node@_msh")
