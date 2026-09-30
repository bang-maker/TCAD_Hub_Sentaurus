(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

; pMOS
(define DopSub "ArsenicActiveConcentration")
(define DopSD  "BoronActiveConcentration")
;----------------------------------------------------------------------
; Setting parameters
; - lateral
(define Lg    0.13)                 ; [um] Gate length
(define Lsp   0.1)                  ; [um] Spacer length
(define Lreox 0.01)                 ; [um] Spacer length
(define Ltot (+ Lg (* 2 Lsp) 0.8) ) ; [um] Lateral extend total 

; - layers
(define Hsub 1.0)   ; [um] Substrate thickness
(define Tox  25e-4) ; [um] Gate oxide thickness
(define Hpol 0.2)   ; [um] Poly gate thickness

; - other
;   - spacer rounding
(define fillet-radius 0.08) ; [um] Rounding radius

;   - pn junction resolution
(define Gpn 0.005) ; [um]

;   - Substrate doping level
(define SubDop 1e18 ) ; [1/cm3]

(define Xj  0.1 ) ; [um] Junction depth

;----------------------------------------------------------------------
; Derived quantities
(define Xmax (/ Ltot 2.0))
(define Xg   (/ Lg   2.0))
(define Xsp  (+ Xg   Lsp))

(define Ysub Hsub)
(define Ygox (* Tox -1.0))
(define Ypol (- Ygox Hpol))

(define Lcont (- Xmax Xsp))  
;----------------------------------------------------------------------
; Overlap resolution: New replaces Old
(sdegeo:set-default-boolean "ABA")

;----------------------------------------------------------------------
; Creating substrate region
(sdegeo:create-rectangle 
  (position    0.0  Ysub  0.0 ) 
  (position    Xmax 0.0 0.0 ) "Silicon" "R.Substrate" )

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

; Creating PolySi gate
(sdegeo:create-rectangle 
  (position    0.0 Ygox 0.0 ) 
  (position    Xg  Ypol 0.0 ) 
  "PolySi" "R.Polygate"
)

;----------------------------------------------------------------------
; - rounding spacer
(sdegeo:fillet-2d 
 (find-vertex-id (position Xsp Ypol 0.0 ))
 fillet-radius)

;----------------------------------------------------------------------
; Contact definitions
(sdegeo:set-contact 
 (find-edge-id (position (* (+ Xmax Xsp)  0.5) 0.0 0.0))
 "drain")
(sdegeo:set-contact 
 (find-edge-id (position 5e-4 Ypol 0.0))
 "gate")
(sdegeo:set-contact 
 (find-edge-id (position 5e-4  Ysub 0.0))
 "substrate")

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

; Source/Drain base line definitions
(sdedr:define-refeval-window "BaseLine.Drain" "Line"  
 (position Xsp 0.0 0.0)  
 (position (* Xmax 2.0) 0.0 0.0) )

; Source/Drain implant definition
(sdedr:define-gaussian-profile "Impl.SDprof"
 DopSD 
 "PeakPos" 0  "PeakVal" 1e20
 "ValueAtDepth" SubDop "Depth" Xj
 "Gauss"  "Factor" 0.4
)

; Source/Drain implants
(sdedr:define-analytical-profile-placement "Impl.Drain" 
 "Impl.SDprof" "BaseLine.Drain" "Symm" "NoReplace" "Eval")

; Source/Drain extensions base line definitions
(sdedr:define-refeval-window "BaseLine.DrainExt" "Line"  
 (position    Xg        0.0 0.0)  
 (position (* Xmax 2.0) 0.0 0.0) )

; Source/Drain implant definition
(sdedr:define-gaussian-profile "Impl.SDextprof"
 DopSD
 "PeakPos" 0  "PeakVal" 5e18
 "ValueAtDepth" SubDop "Depth" (* Xj 0.25)
 "Gauss"  "Factor" 0.25
)

; Source/Drain implants
(sdedr:define-analytical-profile-placement "Impl.DrainExt" 
 "Impl.SDextprof" "BaseLine.DrainExt" "Symm" "NoReplace" "Eval")

;----------------------------------------------------------------------
; Meshing Strategy:
; Substrate
(sdedr:define-refinement-size "Ref.Substrate" 
  (/ Ltot 4.0)  (/ Hsub 8.0) 
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.Substrate" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-region "RefPlace.Substrate" 
 "Ref.Substrate" "R.Substrate" )

; Active
(sdedr:define-refeval-window "RWin.Act" 
 "Rectangle"  
 (position   0.0  0.0   0.0) 
 (position  Xmax (* Xj  1.2)    0.0) )
(sdedr:define-refinement-size "Ref.SiAct" 
  (/ Lcont 4.0) (/ Xj 8.0) 
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.SiAct" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "RefPlace.SiAct" 
 "Ref.SiAct" "RWin.Act" )

; Gate oxide
(sdedr:define-refinement-size "Ref.GOX" 
  (/ Ltot 4.0)  (/ Tox 4.0) 
  Gpn           (/ Tox 8.0) )
(sdedr:define-refinement-region "RefPlace.GOX" 
 "Ref.GOX" "R.Gateox" )

; Gate Multibox
(sdedr:define-refeval-window "MBWindow.Gate" 
 "Rectangle"  
 (position (* Xg -1.0) Ypol  0.0) 
 (position (* Xg  1.0) Ygox  0.0) )
(sdedr:define-multibox-size "MBSize.Gate" 
  (/ Lg  8.0)  (/ Hpol 8.0)
  (/ Lg 10.0)   2e-4 
  1.0         -1.35 )
(sdedr:define-multibox-placement "MBPlace.Gate" 
 "MBSize.Gate"  "MBWindow.Gate" )

; Channel Multibox
(sdedr:define-refeval-window "MBWindow.Channel" 
 "Rectangle"  
 (position        0.0  0.0   0.0) 
 (position (* Xg  1.2) (* 0.5 Xj)  0.0) )
(sdedr:define-multibox-size "MBSize.Channel" 
  (/ Lg  8.0)  (/ Xj 8.0)
  (/ Lg 10.0)   1e-4 
  1.0           1.35 )
(sdedr:define-multibox-placement "MBPlace.Channel" 
 "MBSize.Channel" "MBWindow.Channel" )

; Junctions under the gate
(sdedr:define-refinement-size "Ref.J" 
  (/ 0.016 6.0) 99 
  (/ 0.016 7.0) 66)

; Gate-Drain Junction
(sdedr:define-refeval-window "RWin.GD" 
 "Rectangle"  
 (position (- Xg 0.01)      0.0   0.0) 
 (position (+ Xg Lreox) (* Xj 0.2)  0.0) )
(sdedr:define-refinement-placement "RefPlace.GJ" 
 "Ref.J" "RWin.GD" )

;----------------------------------------------------------------------
; Build Mesh
(sde:build-mesh "n@node@_half_msh")

;----------------------------------------------------------------------
; Reflect the device
(system:command "tdx -mtt -x -M 0 -S 0 -ren drain=source n@node@_half_msh  n@node@_msh")


