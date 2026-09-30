(sde:clear)

(define a 2.0)
(sdegeo:create-rectangle (position       0 0 0) (position (/ a 2) a 0) "Silicon" "RectSi")
(sdegeo:create-rectangle (position (/ a 2) 0 0) (position       a a 0) "Oxide"   "RectOx")
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
