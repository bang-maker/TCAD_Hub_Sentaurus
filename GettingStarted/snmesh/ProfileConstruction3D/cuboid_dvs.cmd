#setdep @previous@

(sde:clear)

(sdegeo:create-cuboid (position 0 (- @yhalf@) 0) (position @depth@ @yhalf@ 1) "Silicon" "bulk")

(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")
