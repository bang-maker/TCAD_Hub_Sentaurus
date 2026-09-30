(sde:clear)

(define a 1.0)
(sdegeo:create-cuboid (position 0 0 0) (position a a a) "Silicon" "Cube")
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
