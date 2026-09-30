(sde:clear)
; UCS coordinate system is default (x points down) 

(define a 2.0)
(sdegeo:create-cuboid (position 0 0 0) (position a a a) "Silicon" "Cube")
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
