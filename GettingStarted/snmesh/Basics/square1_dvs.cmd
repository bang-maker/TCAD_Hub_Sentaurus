(sde:clear)
; UCS coordinate system is default (x points down, y point right) 

(define a 2.0)
(sdegeo:create-rectangle (position 0 0 0) (position a a 0) "Silicon" "Square")
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
