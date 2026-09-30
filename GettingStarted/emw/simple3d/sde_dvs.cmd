;;-----------------------------------------
;; $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple3d/sde_dvs.cmd#1 $
;; Author: Gergoe Letay
(sde:clear)
(sde:set-process-up-direction "+z")

;;--------------------
(display "init parameter")(newline)
;;geometry
(define dair 1) ; um
(define dsub 1) ; um
(define wtot 0.1); um

;; ----------------------------------------
(display "create structure... \n")
(display "  substrate")(newline)
(sdegeo:set-default-boolean "ABA")
(sdegeo:create-cuboid (position 0 0 0) (position wtot wtot dsub) "Silicon" "substrate")

;;--------------------
(display "fill with gas")(newline)
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid (position 0 0 0) (position wtot wtot (- dair)) "Gas" "ambient")

;;--------------------
(display "save boundary")(newline)
(sdeio:save-tdr-bnd "all" "@tdrboundary/o@")
(display "done.")(newline)
