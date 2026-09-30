(sde:clear)

(define dx_pside 0.2)
(define dx_int 0.5)
(define dx_nside 0.2)
(define dx_sub   0.3)

(define xp dx_pside)
(define xi (+ xp dx_int))
(define xn (+ xi dx_nside))
(define xs (+ xn dx_sub))

(define radius_top     2.0)
(define radius_bottom  (+ radius_top (* 0.5 xn)))
(define radius_max radius_bottom)
(define radius_sub (+ radius_bottom 0.2))

(define th_nitride 0.1)

(define dyC 0.1)

(sdegeo:create-rectangle (position  0 0 0) (position xp radius_sub 0) 
  "GaN" "pside")
(sdegeo:create-rectangle (position xp 0 0) (position xi radius_sub 0) 
  "GaN" "iside")
(sdegeo:create-rectangle (position xi 0 0) (position xn radius_sub 0) 
  "GaN" "nside")
(sdegeo:create-rectangle (position xn 0 0) (position xs radius_sub 0) 
  "GaN" "nside")
(sdegeo:bool-unite (find-region-id "nside"))

(sdegeo:create-polygon (list (position 0  radius_top 0) 
  (position 0  radius_sub 0)
  (position xn radius_sub 0)
  (position xn radius_max 0)
  (position 0  radius_top 0)
  )
  "Nitride" "Passivation")

(define dx_Nitride (* 
  (/ (- radius_bottom radius_top) (+ dx_pside dx_int dx_nside)) 
  th_nitride))
(sdegeo:create-polygon (list 
  (position (- th_nitride)  (- radius_top dyC)  0) 
  (position (- th_nitride)  (- (+ radius_top th_nitride) dx_Nitride) 0)
  (position 0 (+ radius_top th_nitride) 0)
  (position 0 (- radius_top dyC) 0)
  (position (- th_nitride)  (- radius_top dyC) 0))
  "Nitride" "Passivation")

(sdegeo:create-polygon (list 
  (position 0  (+ radius_top th_nitride) 0) 
  (position 0  radius_sub 0)
  (position xn radius_sub 0)
  (position xn  (+ radius_max th_nitride) 0)
  (position 0  (+ radius_top th_nitride) 0)
  )
  "Gas" "tmp")
(sdegeo:delete-region (find-region-id "tmp"))
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle 
  (position (- xn th_nitride) 0 0) 
  (position xn radius_sub 0) 
  "Nitride" "Passivation")
(sdegeo:set-default-boolean "ABA")
(sdegeo:bool-unite (find-region-id "Passivation"))

(sdegeo:insert-vertex (position 0  (- radius_top dyC) 0))
(sdegeo:set-contact (list (car (find-edge-id (position xs 0.01 0)))) "cathode")
(sdegeo:set-contact (list (car (find-edge-id (position 0  0.01 0)))) "anode")


;--- doping -------------------------------------------------------------------;
(extract-refwindow (car (entity:faces (find-region-id "iside"))) "REW_iside" )
(sdedr:define-constant-profile "CPD_iside" "NDopantActiveConcentration" 1e15)
(sdedr:define-constant-profile-placement "CPP_iside" "CPD_iside" "REW_iside")

(extract-refwindow (car (entity:faces (find-region-id "pside"))) "REW_pside" )
(sdedr:define-constant-profile "CPD_pside" "PDopantActiveConcentration" 1e19)
(sdedr:define-constant-profile-placement "CPP_pside" "CPD_pside" "REW_pside" 
  0.010 "Gauss")

(extract-refwindow (car (entity:faces (find-region-id "nside"))) "REW_nside" )
(sdedr:define-constant-profile "CPD_nside" "NDopantActiveConcentration" 1e19)
(sdedr:define-constant-profile-placement "CPP_nside" "CPD_nside" "REW_nside" 
  0.010 "Gauss")

(sdegeo:bool-unite (find-material-id "GaN"))
(sde:add-material  (find-material-id "GaN") "GaN" "allGaN")

;--- meshing ------------------------------------------------------------------;
(define xmin (sde:min-x (get-body-list)))
(define xmax (sde:max-x (get-body-list)))
(define ymin (sde:min-y (get-body-list)))
(define ymax (sde:max-y (get-body-list)))

(sdedr:define-refeval-window       "Ref.Win.Global" 
  "Rectangle" (position xmin ymin 0) (position xmax ymax 0))
(sdedr:define-refinement-size      "Ref.Def.Global" 
  0.05 0.1 0.005 0.005 )
(sdedr:define-refinement-function  "Ref.Def.Global" 
  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function  "Ref.Def.Global" 
  "MaxLenInt" "GaN" "Nitride" 0.015 1.2)
(sdedr:define-refinement-placement "Ref.Pla.Global" 
  "Ref.Def.Global" (list "window" "Ref.Win.Global" ) )

(sdedr:define-refeval-window "Ref.Win.ni" 
  "Rectangle"  (position (- xi 0.05) 0 0) (position (+ xi 0.01) radius_sub 0))
(sdedr:define-refinement-size "Ref.Def.ni" 
  0.01 0.1 1 0.001 0.001 1 )
(sdedr:define-refinement-placement "Ref.Pla.ni" 
  "Ref.Def.ni" (list "window" "Ref.Win.ni" ) )

(sdedr:offset-interface "material" "GaN" "Nitride" "hlocal" 0.002 "factor" 1.2)
(sdedr:offset-interface "material" "Nitride" "GaN" "hlocal" 0.005 "factor" 1.4)
(sdedr:offset-block "material" "GaN" "maxlevel" 4)
(sdedr:offset-block "material" "Nitride" "maxlevel" 2)

(sde:build-mesh "" "n@node@")

