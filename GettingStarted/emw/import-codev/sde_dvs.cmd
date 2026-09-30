(sde:clear)
(sde:set-process-up-direction "+z")

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-cuboid 
  (position 0.5 0.5 0.) 
  (position -0.5 -0.5 0.5) 
  "Silicon" "substrate")

;;--------------------
(display "fill with gas")(newline)
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid 
  (position -0.5 -0.5 -0.5) 
  (position 0.5 0.5 0)
  "Gas" "ambient")

;;--------------------
(display "save boundary")(newline)
(sdeio:save-tdr-bnd "all" "@tdrboundary/o@")
