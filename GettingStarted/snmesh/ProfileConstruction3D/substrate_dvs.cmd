#setdep @previous@

(sde:clear)

(define dr     @dr@)
(define radius @radius@)
(define hwidth @hwidth@)
(define depth  -10)

(sdegeo:create-cuboid (position 0 (- 0 hwidth) (- 0 hwidth)) (position depth hwidth hwidth) "Silicon" "sub3q" )

(sdegeo:create-cylinder (position 0 0 0) (position 2 0 0 ) radius "Air" "router" )
(sdegeo:create-cylinder (position 0 0 0) (position 2 0 0) (- radius dr) "Air" "rinner" )
(sdegeo:delete-region (find-region-id "rinner"))
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid (position 0 (- 0 hwidth) (- 0 hwidth))  (position 2 hwidth hwidth) "Insulator1" "dielc" )
(sdegeo:delete-region (find-material-id "Air" ))

(sdegeo:set-default-boolean "ABA")
(sdegeo:create-cuboid (position   0 0 0)  (position depth hwidth hwidth) "Silicon" "sub1q" )

;----------------------------------------------------------------------
; Saving BND file
(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
;----------------------------------------------------------------------
