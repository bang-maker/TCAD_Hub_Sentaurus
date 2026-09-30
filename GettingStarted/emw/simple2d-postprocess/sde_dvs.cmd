;;-----------------------------------------
;; $Id: //tcad/support/main/examples/getting-started/emw/simple2d/sde_dvs.cmd#3 $
(sde:clear)
(sde:set-process-up-direction "+z")

;;--------------------
(display "init parameter")(newline)
;;geometry
(define dair 1)		; um
(define dsub 1)		; um
(define dmet 0.25)	; um
(define wtot 0.1)	; um

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-rectangle (position 0 0 0) (position wtot  dsub 0) "Silicon" "substrate")

(display "  dispersive_material")(newline)
(sdegeo:create-rectangle (position 0 dsub 0) (position wtot (+ dsub dmet) 0)  "Silver" "metal")

;;--------------------
(display "fill with gas")(newline)
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-rectangle (position 0 0 0) (position wtot (- dair) 0) "Gas" "ambient")

;;--------------------
(display "save boundary")(newline)
(sdeio:save-tdr-bnd "all" "@tdrboundary/o@")
(display "done.")(newline)
