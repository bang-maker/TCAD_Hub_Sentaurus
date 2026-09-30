; Reinitializing SDE 
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

; Selecting default Boolean expression 
(sdegeo:set-default-boolean "ABA")

; Creating rectangular regions  
(sdegeo:create-rectangle
  (position -0.5  0.2   0.0) (position 0.5  1.0   0.0) 
  "Silicon" "R.Substrate"
) 
(sdegeo:create-rectangle
  (position -0.5  0.1   0.0) (position 0.5  0.2  0.0) 
  "Oxide" "R.Box"
)
(sdegeo:create-rectangle
  (position -0.5  0.0   0.0) (position 0.5  0.1   0.0) 
  "Silicon" "R.Siliconepi"
) 
(sdegeo:create-rectangle
  (position -0.2 -40e-4 0.0) (position 0.2  0.0   0.0) 
  "Oxide" "R.Gateox"
)
(sdegeo:create-rectangle
  (position -0.2 -0.2   0.0) (position 0.2 -40e-4 0.0) 
  "Nitride" "R.Spacer"
)
(sdegeo:create-rectangle
  (position -0.1 -0.2   0.0) (position 0.1 -40e-4 0.0) 
  "PolySilicon" "R.Polygate"
)

; Rounding edges
(sde:define-parameter "fillet-radius" 0.08 0.0 0.0 )
(sdegeo:fillet-2d (find-vertex-id (position -0.2 -0.2 0.0)) fillet-radius)
(sdegeo:fillet-2d (find-vertex-id (position  0.2 -0.2 0.0)) fillet-radius)

; Defining contacts 
(sdegeo:set-contact (find-edge-id (position -0.4  0.0 0.0)) "source")
(sdegeo:set-contact (find-edge-id (position  0.4  0.0 0.0)) "drain")
(sdegeo:set-contact (find-body-id (position 0.0 -0.1 0.0)) "gate" "remove")
(sdegeo:set-contact (find-edge-id (position  0.0  1.0 0.0)) "substrate")
; Adding extra vertices for bodytie contact
(sdegeo:insert-vertex (position -0.1  0.1 0.0))
(sdegeo:insert-vertex (position -0.05 0.1 0.0))
(sdegeo:set-contact (find-edge-id (position -0.07 0.1 0.0)) "bodytie")

; Saving the model
(sde:save-model "n@node@_geo")
