; Reinitializing SDE 
(sde:clear)

(define Lch 60e-3)
(define Lsd 20e-3)

(define Tsi 10e-3)
(define Tox 2e-3)

(define pplus 1e20)
(define nplus 1e19)

(define nminus 1e14) 

; derived y
(define y2Sub (/ Lch 2))
(define y1Sub (- y2Sub))

(define y1Drain (+ y2Sub))
(define y2Drain (+ y1Drain Lsd))


(define y2Source y1Sub)
(define y1Source (- y2Source Lsd))

; derived x
(define x2Sub (/ Tsi 2))
(define x1Sub (- x2Sub))

(define x1Oxb x2Sub)
(define x2Oxb (+ x1Oxb Tox))

(define x2Oxt x1Sub)
(define x1Oxt (- x2Oxt Tox))


(sdegeo:create-rectangle 
  (position x1Sub y1Sub 0.0 )  (position x2Sub y2Sub 0.0 ) 
  "Silicon" "R.intrinsic" )

(sdegeo:create-rectangle 
  (position x1Sub y1Source 0.0 )  (position x2Sub y2Source 0.0 ) 
  "Silicon" "R.pplus" )

(sdegeo:create-rectangle 
  (position x1Sub y1Drain 0.0 )  (position x2Sub y2Drain 0.0 ) 
  "Silicon" "R.nplus" )

(sdegeo:create-rectangle 
  (position x1Oxt y1Sub 0.0 )  (position x2Oxt y2Sub 0.0 ) 
  "Oxide" "R.Oxt" )

(sdegeo:create-rectangle 
  (position x1Oxb y1Sub 0.0 )  (position x2Oxb y2Sub 0.0 ) 
  "Oxide" "R.Oxb" )


(sdegeo:set-contact 
 (find-edge-id (position x1Oxt 0 0.0)) "gate" )
(sdegeo:set-contact 
 (find-edge-id (position x2Oxb 0 0.0)) "gate")

(sdegeo:set-contact 
 (find-edge-id (position 0 y1Source 0.0)) "source")

(sdegeo:set-contact 
 (find-edge-id (position 0 y2Drain 0.0)) "drain")

(sdedr:define-constant-profile "ND" "PhosphorusActiveConcentration" nplus)

(sdedr:define-constant-profile-region "nplus" "ND" "R.nplus")

(sdedr:define-constant-profile "NA" "BoronActiveConcentration" pplus)

(sdedr:define-constant-profile-region "pplus" "NA" "R.pplus")

(sdedr:define-constant-profile "ND2" "PhosphorusActiveConcentration" nminus)

(sdedr:define-constant-profile-region "nplus2" "ND2" "R.intrinsic")

;--- meshing ------------------------------------------------------------------;
(define xmin (sde:min-x (get-body-list)))
(define xmax (sde:max-x (get-body-list)))
(define ymin (sde:min-y (get-body-list)))
(define ymax (sde:max-y (get-body-list)))
(define zmin (sde:min-z (get-body-list)))
(define zmax (sde:max-z (get-body-list)))

(define xsteps_min 10)
(define xsteps_max 20)

(define ysteps_min 10)
(define ysteps_max 20)

(define zsteps_min 10)
(define zsteps_max 20)

(sdedr:define-refeval-window       "Ref.Win.Global" 
  "Rectangle" (position xmin ymin zmin) (position xmax ymax zmax))
(sdedr:define-refinement-size      "Ref.Def.Global" 
  (/ (- xmax xmin) xsteps_min)  (/ (- ymax ymin) ysteps_min)  (/ (- zmax zmin) zsteps_min)  
  (/ (- xmax xmin) xsteps_max)  (/ (- ymax ymin) ysteps_max) (/ (- zmax zmin) zsteps_max)
  )
(sdedr:define-refinement-function  "Ref.Def.Global" 
  "DopingConcentration" "MaxTransDiff" 1)

(sdedr:define-refinement-function  "Ref.Def.Global"
  "MaxLenInt" "R.intrinsic" "R.pplus" 0.1e-3 1.5 "DoubleSide" "UseRegionNames")

(sdedr:define-refinement-function  "Ref.Def.Global"
  "MaxLenInt" "R.intrinsic" "R.nplus" 0.5e-3 1.5 "DoubleSide" "UseRegionNames")

(sdedr:define-refinement-function  "Ref.Def.Global"
  "MaxLenInt" "Silicon" "Oxide" 0.5e-3 1.5 "DoubleSide")

(sdedr:define-refinement-function  "Ref.Def.Global" 
  "MaxLenInt" "All" "Contact" 0.5e-3)

(sdedr:define-refinement-placement "Ref.Pla.Global" 
  "Ref.Def.Global" (list "window" "Ref.Win.Global" ) )

(sde:build-mesh "n@node@")



