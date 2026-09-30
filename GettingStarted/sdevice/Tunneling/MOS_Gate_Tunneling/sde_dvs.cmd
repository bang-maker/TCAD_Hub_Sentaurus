; Some internal variables for easy parameterization

#if "@GateMat@"!="-"
(define Gate_Material "@GateMat@")
#else
(define Gate_Material "XXX")
#endif

(define Gate_N	1e21)
(define Gate_Doping_Sp "ArsenicActiveConcentration")

(define Ins_Material "@InsMat@")
(define tox	@<tbox*1e-3>@)

(define Channel_N 1e18)
#if "@Type@"=="nMOS"
(define Channel_Doping_Sp "BoronActiveConcentration")
#else
(define Channel_Doping_Sp "ArsenicActiveConcentration")
#endif

(define LenHalf 0.04)
(define tSub 0.1)

;--- Boundary ---------------------------------------------------------------------;
(sdegeo:create-rectangle (position -0.02 (- LenHalf)    0) (position (- tox) LenHalf  0) Gate_Material "r.polysi")
(sdegeo:create-rectangle (position (- tox) (- LenHalf)  0) (position 0  LenHalf       0) Ins_Material "r.ox")
(sdegeo:create-rectangle (position 0 (- LenHalf)       0) (position tSub LenHalf      0) "Silicon" "r.si")

;--- Contacts ---------------------------------------------------------------------;
(sdegeo:define-contact-set "top")
(sdegeo:set-current-contact-set "top")
#if "@GateMat@"!="-"
(sdegeo:define-2d-contact (find-edge-id (position -0.02 0  0)) "top")
#else
(sdegeo:set-contact-boundary-edges (find-material-id "XXX"))
(sdegeo:delete-region (find-material-id "XXX"))
#endif

(sdegeo:define-contact-set "bot")
(sdegeo:set-current-contact-set "bot")
(sdegeo:define-2d-contact (find-edge-id (position tSub 0   0)) "bot") 

;--- Doping ------------------------------------------------------------------;
(sdedr:define-constant-profile "DC.fg" Gate_Doping_Sp Gate_N)
(sdedr:define-constant-profile-region "CPM.fg" "DC.fg" "r.polysi")

(sdedr:define-constant-profile "DC.channel" Channel_Doping_Sp Channel_N)
(sdedr:define-constant-profile-region "CPM.channel" "DC.channel" "r.si")

;--- meshing ------------------------------------------------------------------;
(define xmin (sde:min-x (get-body-list)))
(define xmax (sde:max-x (get-body-list)))
(define ymin (sde:min-y (get-body-list)))
(define ymax (sde:max-y (get-body-list)))
(define zmin (sde:min-z (get-body-list)))
(define zmax (sde:max-z (get-body-list)))

#define scale_fac @mesh_fac@

(sdedr:define-refeval-window       "Ref.Win.Global" 
  "Rectangle" (position xmin ymin 0) (position xmax ymax 0))

(sdedr:define-refinement-size      "Ref.Def.Global" 
  (/ (- xmax xmin) @<20/scale_fac>@)  (/ (- ymax ymin) 2)  (/ (- zmax zmin) 5)  
  (/ (- xmax xmin) @<40/scale_fac>@)  (/ (- ymax ymin) 2) (/ (- zmax zmin) 10)
  )

#if "@GateMat@"!="-"
(sdedr:define-refinement-function "Ref.Def.Global" "MaxLenInt" "r.polysi"  "r.ox" 4e-4 2 "UseRegionNames" "DoubleSide")
#endif

#if @IntMesh@
(sdedr:define-refinement-function "Ref.Def.Global" "MaxLenInt" "r.ox" "r.si"  1e-4 2 "UseRegionNames")
#endif

(sdedr:define-refinement-placement "Ref.Pla.Global" 
  "Ref.Def.Global" (list "window" "Ref.Win.Global" ) )

(sdedr:define-refinement-window "RW.gateox" "Rectangle" (position (- tox) -1 0) (position  tox 1 0))
(sdedr:define-refinement-size  "RS.gateox"  (/ tox @<2/scale_fac>@) 999 (/ tox @<3/scale_fac>@) 888 )
(sdedr:define-refinement-placement "RP.gateox" "RS.gateox" "RW.gateox")

(sdedr:define-refinement-window "RW.gateox1" "Rectangle" (position -2.5e-3 -1 0) (position  -1.5e-3 1 0))
(sdedr:define-refinement-size  "RS.gateox1"  @<1e-3*scale_fac>@ 999 @<1e-4*scale_fac>@ 888 )
(sdedr:define-refinement-placement "RP.gateox1" "RS.gateox1" "RW.gateox1")

; Build mesh and save device
(sde:build-mesh "snmesh" "-H" "n@node@_msh")

