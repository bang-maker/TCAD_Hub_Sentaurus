; Reinitializing SDE 
(sde:clear)


(define Wsi @SiWidth@)  ; Width  of Silicon Region
(define Hsi 1.0)        ; Height of Silicon Region
(define Wpo 0.5)        ; Width  of Poly Region
(define Hpo 0.5)        ; Height of Poly Region

(define SiPoOver (* 0.5 Hpo)); Overlap of both regions

(define Nd 1e20)        ; Poly    doping level
(define Na 1e18)        ; Silicon doping level

(define NumberOfPointsXsi 8) ; Number of grid points in Silicon
(define NumberOfPointsYsi 8)

(define NumberOfPointsXpo 8) ; Number of grid points in Silicon
(define NumberOfPointsYpo 8)

(sdegeo:create-rectangle 
  (position 0.0 (* -0.5 Wsi)  0.0 )  (position Hsi (* 0.5 Wsi)  0.0 ) 
  "Silicon" "R.Silicon" )
(sdegeo:set-default-boolean "ABA")

(define Xpo1 SiPoOver)
(define Xpo2 (- Xpo1 Hpo))

(sdegeo:create-rectangle 
  (position Xpo1 (* -0.5 Wpo)   0.0 )  (position Xpo2 (* 0.5 Wpo)  0.0 ) 
  "PolySi" "R.Poly" )

(sdegeo:set-contact 
 (find-edge-id (position Xpo2 0.0  0.0)) "Top" )
(sdegeo:set-contact 
 (find-edge-id (position Hsi 0.0  0.0)) "Bot")

(sdedr:define-constant-profile "PolyProf" "ArsenicActiveConcentration" Nd)

(sdedr:define-constant-profile-material "PolyDop" "PolyProf" "PolySi")

(sdedr:define-constant-profile "SiProf" "BoronActiveConcentration" Na)

(sdedr:define-constant-profile-material "SiDop" "SiProf" "Silicon")


(sdedr:define-refinement-size "SiRef" 
 (/ Wsi NumberOfPointsXpo)       (/ Hsi NumberOfPointsYpo)       1.0
 (/ Wsi (* 2 NumberOfPointsXpo)) (/ Hsi (* 2 NumberOfPointsYpo)) 0.5 )
(sdedr:define-refinement-material "SiRef" "SiRef" "Silicon" )

(sdedr:define-refinement-size "PolyRef" 
 (/ Wpo NumberOfPointsXpo)       (/ Hpo NumberOfPointsYpo)       1.0
 (/ Wpo (* 2 NumberOfPointsXpo)) (/ Hpo (* 2 NumberOfPointsYpo)) 0.5 )
(sdedr:define-refinement-function "PolyRef" "MaxLenInt" "PolySi" "Silicon" 0.005 1.4)
(sdedr:define-refinement-material "PolyRef" "PolyRef" "PolySi" )


;Meshing the device
(sde:build-mesh "n@node@")


