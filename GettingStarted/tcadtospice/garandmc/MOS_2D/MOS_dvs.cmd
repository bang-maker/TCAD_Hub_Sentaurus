(if (string=? "@Type@" "nMOS") 
 (begin
  (define DopSub "BoronActiveConcentration")
  (define DopSD  "ArsenicActiveConcentration")

; - Substrate doping and constant stress 
  (define SubDop  5e15 )     ; [1/cm3]
  (define HaloDop 4.0e18 )   ; [1/cm3]
  (define StressYV  1.5e9 )  ; [Pa]
 )
 (begin 
  (define DopSub "ArsenicActiveConcentration")
  (define DopSD  "BoronActiveConcentration")
  
;   - Substrate doping level
  (define SubDop  1e17 )      ; [1/cm3]
  (define HaloDop 3.0e18 )    ; [1/cm3]
  (define StressYV  -1.5e9 )  ; [Pa]
 )
)
;----------------------------------------------------------------------
(sde:set-process-up-direction "-x")
;----------------------------------------------------------------------
; Setting parameters

; - lateral
(define Lg    @lgate@)                ; [um] Gate length
(define Lsp   0.014)                  ; [um] Spacer length
(define LReox 0.0025)                 ; [um] Reox Spacer length
(define Ltot (+ Lg (* 2 Lsp) 0.05) )  ; [um] Lateral extend total

(define Tox 0.0006)    ; [um] Gate oxide thickness 
(define THF 0.0020)    ; [um] HighK oxide thickness 
(define TMetal 0.005)  ; [um] MetalGate thickness 

; - layers
(define Tsub 1.0)      ; [um] Substrate thickness
(define Tpol 0.035)    ; [um] Poly gate thickness

;   - pn junction resolution
(define Gpn 0.001)     ; [um]
(define XjWELL 0.12)   ; [um] Well depth
(define XjHalo 0.05)   ; [um] Halo depth
(define XjExt  0.008)  ; [um] Extension depth
(define XjSD   0.040)  ; [um] SD Junction depth

;----------------------------------------------------------------------
; Derived quantities
(define Ymax (/ Ltot   2.0))
(define Yg   (/ Lg   2.0))
(define Ysp  (+ Yg   Lsp))
(define Yrox (+ Yg   LReox))

(define Xsub Tsub)
(define Xgox (* Tox -1.0))
(define XHF  (- Xgox THF))
(define XMetal  (- XHF TMetal))
(define Xpol (- XMetal Tpol))
(define Lcont (- Ymax Ysp))  
;----------------------------------------------------------------------
; Overlap resolution: New replaces Old
(sdegeo:set-default-boolean "ABA")
;----------------------------------------------------------------------
; Creating substrate region
(sdegeo:create-polygon (list 
  (position  0.0  0.0  0.0) (position  0.0  Yg  0.0) (position 0.0015 (+ Yg 0.0016) 0.0) 
  (position  0.0015  Ysp  0.0) (position 0.01 (+ Ysp 0.009) 0.0) (position  0.01 Ymax 0.0) 
  (position  Xsub  Ymax  0.0) (position  Xsub  0.0  0.0)) "Silicon" "R.Substrate" )

; Creating gate oxide
(sdegeo:create-rectangle 
  (position    0.0 0.0  0.0 ) 
  (position    Xgox Yg 0.0 ) 
  "SiO2" "R.Gateox"
)

; Creating High-K MetalGate
(sdegeo:create-rectangle 
  (position    Xgox 0.0  0.0 ) 
  (position    XHF Yg 0.0 ) 
  "HfO2" "R.HighK"
)
(sdegeo:create-rectangle 
  (position    XHF 0.0 0.0 ) 
  (position    XMetal Yg 0.0 ) 
  "AlN" "R.MetalG"
)

; Creating PolySi gate
(sdegeo:create-rectangle 
  (position    XMetal 0.0 0.0 ) 
  (position    Xpol Yg 0.0 ) 
  "PolySi" "R.Polygate"
)

; Creating PolyReox
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle 
  (position    0.0015  Yg 0.0 ) 
  (position    (+ Xpol 0.01) Ysp 0.0 ) 
  "Oxide" "R.PolyReoxRight"
)

; Creating spacers regions
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle 
  (position   Xgox  (+ Yg LReox) 0.0 ) 
  (position   (+ Xpol 0.01) Ysp 0.0 ) 
  "Si3N4" "R.Spacer"
)

;;;;;;;
(if (string=? "@Type@" "nMOS") 
 (begin
 
; Creating Silicide region
 (sdegeo:create-polygon (list 
  (position  Xgox  Ysp  0.0) (position  0.0015  Ysp  0.0) (position 0.01 (+ Ysp 0.009) 0.0) 
  (position  0.01  Ymax  0.0) (position 0.008 Ymax 0.0) (position  0.006 (+ Ysp 0.009) 0.0) 
  ) "Metal" "R.Silicide" )
   
; - rounding silicide
 (sdegeo:fillet-2d 
 (find-vertex-id (position 0.01 (+ Ysp 0.009) 0.0))
 0.02)

 (sdegeo:fillet-2d 
 (find-vertex-id (position 0.006 (+ Ysp 0.009) 0.0))
 0.02)


)
 (begin 

; Creating SiGe Pocket
 (sdegeo:create-polygon (list 
  (position  0.0  Yg  0.0) (position  0.007  Yg  0.0) (position 0.007 (- Ysp 0.005) 0.0) 
  (position  0.03  (- Ysp 0.005)  0.0) (position 0.03 Ymax 0.0) (position  -0.005 Ymax 0.0)
  (position  -0.025 (+ Ysp 0.0075) 0.0) (position  -0.02 Ysp 0.0) (position  0.0015  Ysp  0.0) 
  (position 0.0015 (+ Yg 0.0016) 0.0)) "Silicon" "R.Pocket" )


; Creating Silicide region
 (sdegeo:create-polygon (list 
  (position  -0.02 Ysp 0.0) (position  -0.023  Ysp  0.0) (position  -0.028 (+ Ysp 0.0075) 0.0) 
  (position  -0.008 Ymax 0.0) (position  -0.005 Ymax 0.0) (position  -0.025 (+ Ysp 0.0075) 0.0)) "Metal" "R.Silicide" )

 (sdegeo:fillet-2d 
 (find-vertex-id (position  -0.025 (+ Ysp 0.0075) 0.0))
 0.01)


 (sdegeo:fillet-2d 
 (find-vertex-id (position  -0.028 (+ Ysp 0.0075) 0.0))
 0.01)


 (sdegeo:fillet-2d 
 (find-vertex-id (position  0.007  Yg  0.0))
 0.005)

 (sdegeo:fillet-2d 
 (find-vertex-id (position  0.03  (- Ysp 0.005)  0.0))
 0.01)
    
 )
)

(sdeio:save-tdr-bnd "all" "n@node@_S1_bnd.tdr")

;----------------------------------------------------------------------
; - rounding spacer and remove PolySilicon
(sdegeo:fillet-2d 
 (find-vertex-id (position (+ Xpol 0.01) Ysp 0.0 ))
 0.08)
 
(sdegeo:delete-region (find-body-id (position (+ Xpol 0.001) (/ Yg 2.0) 0.0 )))

;----------------------------------------------------------------------
; Contact settings
(if (string=? "@Type@" "nMOS") 
 (begin

(sdegeo:define-contact-set "drain" 4.0  (color:rgb 0.0 1.0 0.0 ) "##")
(sdegeo:set-current-contact-set "drain")
(sdegeo:set-contact-boundary-edges (find-body-id (position 0.009 (- Ymax 0.001) 0.0))
 "drain")

(sdegeo:delete-region (find-body-id (position 0.009 (- Ymax 0.001) 0.0)))
 )

 (begin

(sdegeo:define-contact-set "drain" 4.0  (color:rgb 0.0 1.0 0.0 ) "##")
(sdegeo:set-current-contact-set "drain")
(sdegeo:set-contact-boundary-edges (find-body-id (position -0.008 (- Ymax 0.001) 0.0))
 "drain")

(sdegeo:delete-region (find-body-id (position -0.008 (- Ymax 0.001) 0.0)))
 
 )
)

(sdegeo:define-contact-set "gate" 4.0  (color:rgb 0.0 0.0 1.0 ) "##")
(sdegeo:set-current-contact-set "gate")
(sdegeo:set-contact-boundary-edges (find-body-id  (position (+ XMetal 0.001) 5e-4 0.0 ))
 "gate")
(sdegeo:delete-region (find-body-id (position (+ XMetal 0.001) 5e-4 0.0 )))

(sdegeo:define-contact-set "substrate" 4.0  (color:rgb 1.0 0.0 0.0 ) "##")
(sdegeo:set-current-contact-set "substrate")
(sdegeo:set-contact 
 (find-edge-id (position  Xsub 5e-4 0.0))
 "substrate")
 
;----------------------------------------------------------------------
; Separating lumps
(sde:separate-lumps)

; Setting region names
(sde:add-material 
  (find-body-id (position  (- Xsub 0.1) 5e-4 0.0)) 
  "Silicon" "R.Substrate")

(sde:add-material 
  (find-body-id (position  (* 0.5 Xgox) 5e-4 0.0)) 
  "SiO2"    "R.Gateox")

(sde:add-material 
  (find-body-id (position  (* 0.5 XHF) 5e-4 0.0)) 
  "HfO2"    "R.HighK")

(sde:add-material 
  (find-body-id (position 0.009 (- Ymax 0.001) 0.0)) 
  "Metal"    "R.nSilicide")  

(sde:add-material 
  (find-body-id (position -0.022 (+ Ysp 0.001) 0.0)) 
  "Metal"    "R.pSilicide")

(if (string=? "@Type@" "pMOS") 
 (begin
(sde:add-material 
  (find-body-id (position 0.02 (- Ymax 0.001) 0.0)) 
  "Silicon"  "R.SiRight")  
 )
)
  
(sde:add-material 
  (find-body-id (position (- Xgox 0.01) (* -0.5 (+ Ysp Yg))  0.0)) 
  "Si3N4"   "R.Spacerleft")

(sde:add-material 
  (find-body-id (position (- Xgox 0.01) (*  0.5 (+ Ysp Yg))  0.0))  
  "Si3N4"   "R.SpacerRight")

(sdeio:save-tdr-bnd "all" "n@node@_S2_bnd.tdr")

;----------------------------------------------------------------------
; Profiles:

; - Substrate
(sdedr:define-constant-profile "Const.Substrate" 
 DopSub SubDop )
(sdedr:define-constant-profile-region  "PlaceCD.Substrate" 
 "Const.Substrate" "R.Substrate" )

; - Halo -- base line definitions
(sdedr:define-refeval-window "BaseLine.Halo" "Line"  
 (position 0.01 Yg 0.0 )  
 (position 0.01 Ymax 0.0 ) )
; -- implant definition
(sdedr:define-gaussian-profile "Impl.Haloprof"
 DopSub
 "PeakPos" 0  "PeakVal" HaloDop
 "ValueAtDepth" 1e16  "Depth" XjHalo
 "Gauss"  "Factor" 0.8
)

; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.Halo" 
 "Impl.Haloprof" "BaseLine.Halo" "Both" "NoReplace" "Eval")
 
; - Source/Drain extensions (LDD) -- base line definitions
(sdedr:define-refeval-window "BaseLine.Ext" "Line"  
 (position    0.0 Yrox 0.0)  
 (position    0.0 Ymax 0.0) )
;   implant definition
(sdedr:define-gaussian-profile "Impl.Extprof"
 DopSD
 "PeakPos" 0  "PeakVal" 1.5e20
 "ValueAtDepth" 5e18 "Depth" XjExt
 "Gauss"  "Factor" 0.65
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.Ext" 
 "Impl.Extprof" "BaseLine.Ext" "Both" "NoReplace" "Eval")

; - Source/Drain implants (HDD)

(sdedr:define-refeval-window "BaseLine.SD" "Line"  
 (position 0.0015 (+ Ysp 0.017) 0.0)  
 (position 0.0015 (* Ymax 2.0) 0.0) )
; -- implant definition
(sdedr:define-gaussian-profile "Impl.SDprof"
 DopSD 
 "PeakPos" 0  "PeakVal" 1.5e20
 "ValueAtDepth" 5e17 "Depth" XjSD
 "Gauss"  "Factor" 0.65
)
; -- implant placement
(sdedr:define-analytical-profile-placement "Impl.SD" 
 "Impl.SDprof" "BaseLine.SD" "Both" "NoReplace" "Eval")

;----------------------------------------------------------------------
; Meshing Strategy:
; Substrate

(sdedr:define-refinement-size "Ref.Substrate" 
  (/ Xsub 8.0)  (/ Ymax 4.0)
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.Substrate" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-region "RefPlace.Substrate" 
 "Ref.Substrate" "R.Substrate" )

; Active
(sdedr:define-refeval-window "RWin.Act" 
 "Rectangle"  
 (position   0.0  0.0  0.0) 
 (position  (* XjSD 1.5) Ymax  0.0) )
(sdedr:define-refinement-size "Ref.SiAct" 
 (/ XjSD 5.0) (/ Lcont 5.0)
  Gpn            Gpn )
(sdedr:define-refinement-function "Ref.SiAct" 
 "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-placement "RefPlace.SiAct" 
 "Ref.SiAct" "RWin.Act" )

; GateOx Multibox
(sdedr:define-refeval-window "MBWindow.GateOx" 
 "Rectangle"  
 (position Xgox   0.0        0.0) 
 (position 0.001 (* Yg 1.1) 0.0) )
(sdedr:define-multibox-size "MBSize.GateOx" 
  (/ Tox 3.0) (/ Lg  8.0) 
  1e-3        (/ Lg 10.0)
  1.0         -1.35 )
(sdedr:define-multibox-placement "MBPlace.GateOx" 
 "MBSize.GateOx"  "MBWindow.GateOx" )

; Channel Multibox
(sdedr:define-refeval-window "MBWindow.Channel" 
 "Rectangle"  
 (position  0.0  0.0  0.0) 
 (position  (* 2.0 XjExt) (* Yg 1.2)  0.0) )
(sdedr:define-multibox-size "MBSize.Channel" 
  (/ XjSD 8.0) (/ Lg  8.0)
   1e-4        (/ Lg 10.0)
   1.0           1.35 )
(sdedr:define-multibox-placement "MBPlace.Channel" 
 "MBSize.Channel" "MBWindow.Channel" )

; Junctions under the gate
(sdedr:define-refinement-size "Ref.J" 
  (/ XjExt 8.0)  (/ XjExt 8.0) 
  (/ XjExt 10.0) (/ XjExt 10.0))

; Gate-Drain Junction
(sdedr:define-refeval-window "RWin.GD" 
 "Rectangle"  
 (position 0.0           (- Yrox (* 0.8 XjExt))  0.0) 
 (position (* 2.0 XjExt) (+ Yrox (* 1.0 XjExt))  0.0) )
(sdedr:define-refinement-placement "RefPlace.GJ" 
 "Ref.J" "RWin.GD" )

(sdesnmesh:axisaligned "fitInterfaces" #t)

(sdesnmesh:iocontrols "EnableSections" #t "useUCScoordinates" #t  "unstructuredTensorMesh" #t "saveInterfaceRegions" #t)
;----------------------------------------------------------------------
; Build Mesh 
(sde:build-mesh "n@node@_half_msh")

;----------------------------------------------------------------------
; Reflect device
(if (string=? "@Type@" "pMOS") 
 (begin
 (system:command "tdx -mtt -y -ren drain=source/R.PolyReoxRight=R.PolyReoxLeft/R.SiRight=R.SiLeft/R.SpacerRight=R.SpacerLeft n@node@_half_msh n@node@_msh")
 )
 (begin
 (system:command "tdx -mtt -y -ren drain=source/R.PolyReoxRight=R.PolyReoxLeft/R.SpacerRight=R.SpacerLeft n@node@_half_msh n@node@_msh")  
 )
)

;----------------------------------------------------------------------
; Extract Boundary
(sde:extract-tdr-boundary "n@node@_msh.tdr")

