(sde:clear)

(sdegeo:create-rectangle (position  0    0    0.0 )  (position 2    2    0.0 ) "Silicon"       "Substrate" )
(sdegeo:create-circle (position 0 1 0)  0.8 "Oxide" "circ_oxide" )
(sdegeo:create-rectangle (position 0 0 0 )  (position -2 2 0 ) "Vacuum" "tmp" )
(sdegeo:delete-region (find-region-id "tmp"))

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
