(sde:clear)

(sdegeo:create-rectangle (position  0    0    0.0 )  (position 2    2    0.0 ) "Silicon"       "Substrate" )
(sdegeo:create-circle (position 0 1 0)  0.8 "Oxide" "circ_oxide" )
(sdegeo:create-rectangle (position 0 0 0 )  (position -2 2 0 ) "Vacuum" "tmp" )
(sdegeo:delete-region (find-region-id "tmp"))

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")

;(sdedr:define-refeval-window       "REW_Global" "Rectangle"  (position 0 0 0) (position 2 2 0))
;(sdedr:define-refinement-size      "RED_Global" 1 1 1 0.01 0.01 1 )
;(sdedr:define-refinement-function  "RED_Global" "MaxLenInt" "Silicon" "Oxide" 0.01 2 "DoubleSide")
;(sdedr:define-refinement-placement "REP_Global" "RED_Global" "REW_Global" )
;(sdedr:write-cmd-file  "n@node@_msh.cmd")

