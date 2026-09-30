(sde:clear)

(sdegeo:create-rectangle (position 0 0 0) (position 3 1 0) "Silicon" "region_1")

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
