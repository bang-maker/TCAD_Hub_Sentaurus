(sde:clear)

(sdegeo:create-rectangle (position  0    0    0.0 )  (position 1     2    0.0 ) "Silicon"       "Substrate" )
(sdegeo:create-rectangle (position  0    0    0.0 )  (position -1    2    0.0 ) "Oxide"         "Oxide" )
(sdegeo:create-rectangle (position -0.25 0.5  0.0 )  (position -0.75 1.5  0.0 ) "PolySilicon"   "Poly" )

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
  
;(sdedr:define-refeval-window       "REW_Global" "Rectangle"  (position -1 0 0) (position 1 2 0))
;(sdedr:define-refinement-size      "RED_Global" 1 1 1 0.01 0.01 0.01 )
;(sdedr:define-refinement-function  "RED_Global" "MaxLenInt" "PolySilicon" "Oxide" 0.01 2 "DoubleSide")
;(sdedr:define-refinement-function  "RED_Global" "MaxLenInt" "Silicon" "Oxide" 0.01 2 "DoubleSide")
;(sdedr:define-refinement-placement "REP_Global" "RED_Global" "REW_Global" )

;(sdedr:write-cmd-file  "n@node@_msh.cmd")
