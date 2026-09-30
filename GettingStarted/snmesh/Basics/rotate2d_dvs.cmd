(sde:clear)
; UCS coordinate system is default (x points down) 

(define a 2.0)
(sdegeo:create-rectangle (position 0 0 0) (position a a 0) "Silicon" "Square")
(define square (find-region-id "Square"))
(sdegeo:rotate-selected  square (transform:rotation (position 0 0 0) (gvector 0 0 1) 45)  #f 0)
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
