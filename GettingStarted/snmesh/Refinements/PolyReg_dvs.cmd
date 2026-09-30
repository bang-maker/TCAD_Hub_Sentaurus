(sde:clear)

(define a 2.0)
(sdegeo:create-rectangle (position 0 0 0) (position a a 0) "Silicon" "Square")

(define polygon_coordinates (list
    (position 5.29e-01 7.25e-01 0)
    (position 8.79e-01 4.38e-01 0)
    (position 1.36e+00 8.25e-01 0)
    (position 1.24e+00 1.30e+00 0)
    (position 6.90e-01 1.37e+00 0)
    (position 4.96e-01 1.06e+00 0)
    (position 5.29e-01 7.25e-01 0)
))
(sdegeo:create-polygon  polygon_coordinates "Silicon" "PolygonR")

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
