
(define Tfe  @Tfe@) ; [um] Thickness of ferroeelectric layer
(define Lfe  @Lfe@) ; [um] Length of ferroeelectric layer

(sdegeo:create-rectangle
  (position 0 0 0) (position Tfe Lfe 0) 
  "HfO2" "Reg.FE"
)

(sdegeo:set-contact (find-edge-id (position 0.0  (/ Lfe 2) 0.0)) "top")
(sdegeo:set-contact (find-edge-id (position Tfe (/ Lfe 2) 0.0)) "bottom")

;; Meshing Strategy
;--------------------------
; global mesh
(define xmin (position:x (car (bbox (get-body-list)))))
(define xmax (position:x (cdr (bbox (get-body-list)))))
(define ymin (position:y (car (bbox (get-body-list)))))
(define ymax (position:y (cdr (bbox (get-body-list)))))
(define zmin (position:z (car (bbox (get-body-list)))))
(define zmax (position:z (cdr (bbox (get-body-list)))))

(define minStepsx 15)
(define maxStepsx 100)
(define minStepsy 15)
(define maxStepsy 100)

(sdedr:define-refinement-window "Ref.Win.Global" "Cuboid" (position xmin ymin zmin) (position xmax ymax zmax))
(sdedr:define-refinement-size "Ref.Size.Global" 
      (/ (- xmax xmin) minStepsx) (/ (- ymax ymin) minStepsy) 0 
      (/ (- xmax xmin) maxStepsx) (/ (- ymax ymin) maxStepsy) 0       
 )
(sdedr:define-refinement-placement "Ref.Place.Global" "Ref.Size.Global" "Ref.Win.Global")
(sdedr:define-refinement-function "Ref.Size.Global" "MaxLenInt" "All" "Contact" 0.001 1.2)

(sde:build-mesh "n@node@")
