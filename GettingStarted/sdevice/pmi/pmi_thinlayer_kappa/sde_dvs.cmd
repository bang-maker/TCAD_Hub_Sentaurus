(sde:clear)
(define tiny 1e-5)

(define thick 0.050)
(define thin  0.005)
(define ll    0.100)
(define lc    0.100)
(define lr    0.100)

(define Xthick (/ thick 2))
(define Xthin  (/ thin  2))
(define xthick (- Xthick))
(define xthin  (- Xthin ))

(define yl 0)
(define Yl (+ yl ll))
(define yc Yl)
(define Yc (+ yc lc))
(define yr Yc)
(define Yr (+ yr lr))

(define dyiso 0.02)
(define xiso xthick)
(define Xiso Xthick)
(define Yisol yl)
(define yisol (- Yisol dyiso))
(define yisor Yr)
(define Yisor (+ yisor dyiso))


(sdegeo:create-rectangle (position xiso yl 0) (position Xiso Yr 0)
  "Oxide" "isolation")


(sdegeo:create-polygon (list (position xthick yl 0) (position xthin  Yl 0)
  (position Xthin  Yl 0) (position Xthick yl 0)
  (position xthick yl 0)
  )
  "Silicon" "wire")
(sdegeo:create-rectangle (position xthin  yc 0) (position Xthin  Yc 0)
  "Silicon" "wire")
(sdegeo:create-polygon (list (position xthin  yr 0) (position xthick Yr 0)
  (position Xthick Yr 0) (position Xthin  yr 0)
  (position xthin  yr 0)
  )
  "Silicon" "wire")
(sdegeo:bool-unite (find-material-id "Silicon"))


(sdegeo:create-rectangle (position xiso yisol 0) (position Xiso Yisol 0)
  "Gold" "cl")
(sdegeo:create-rectangle (position xiso yisor 0) (position Xiso Yisor 0)
  "Gold" "cr")
(sdegeo:set-contact (find-region-id "cl") "c1")
(sdegeo:set-contact (find-region-id "cr") "c2")
(sdegeo:delete-region (find-material-id "Gold"))


(sdedr:define-refeval-window "REW_l" "Rectangle"  (position xthick yl 0) (position Xthick yr 0))
(sdedr:define-gaussian-profile "APD_l" "BoronActiveConcentration" "PeakPos" 0  "PeakVal" 5e+18 "StdDev" 0.005 "Gauss"  "Factor" 1)
(sdedr:define-analytical-profile-placement "APP_l" "APD_l" "REW_l" "Both" "NoReplace" "Eval" "Silicon" 0 "material")

(sdedr:define-refeval-window "REW_r" "Rectangle"  (position xthick Yl 0) (position Xthick Yr 0))
(sdedr:define-gaussian-profile "APD_r" "PhosphorusActiveConcentration" "PeakPos" 0  "PeakVal" 5e+18 "StdDev" 0.005 "Gauss"  "Factor" 1)
(sdedr:define-analytical-profile-placement "APP_r" "APD_r" "REW_r" "Both" "NoReplace" "Eval" "Silicon" 0 "material")

(define Dx (/ (- Xiso xiso) 16))
(define dx (/ Dx 4))
(define Dy (/ (- Yr yl) 64))
(define dy (/ Dy 4))
(sdedr:define-refeval-window "REW_glob" "Rectangle"  (position xiso yl 0) (position Xiso Yr 0))
(sdedr:define-refinement-size "RED_glob" Dx Dy 1 dx dy 1 )
(sdedr:define-refinement-placement "REP_glob" "RED_glob" (list "window" "REW_glob" ) )

(sdedr:offset-interface "material" "Silicon" "Oxide" "hlocal" (/ thin 7) "factor" 1.0)
(sdedr:offset-block "material" "Silicon" "maxlevel" 3)
(sdedr:offset-block "material" "Oxide" "maxlevel" 2)

(sde:build-mesh "n@node@_msh")