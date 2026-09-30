(sde:clear)

(display "define constants... \n")
;;geometry
(define dsub 1) ; um
(define wtot 1); um
;; refinements
(define xref 10)
(define yref 10)
;; others
(define myNode "@node@")

;; ----------------------------------------
(display "create structure... \n")

(display "  substrate")(newline)
(sdegeo:create-rectangle 
  (position 0 0 0) 
  (position dsub wtot 0) 
  "Silicon" "substrate")

;; ----------------------------------------
(display "Define Contacts... \n")
(display "  arc Contact... \n")
(sdegeo:define-contact-set "dummy" 4  (color:rgb 0 1 0 ) "##" )
(sdegeo:set-contact (find-edge-id (position 0 0.5 0)) "dummy")
(sde:refresh)

		;;----------------------------------------
(display "put dummy doping\n")
(sdedr:define-refeval-window "default" "Rectangle"  (position 0 0 0)  (position dsub wtot 0) )
(sdedr:define-constant-profile "ConstantProfileDefinition_1" "BoronActiveConcentration" 1e13)
(sdedr:define-constant-profile-placement "ConstantProfilePlacement_1" "ConstantProfileDefinition_1" "default")

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refinement-window "global" "Rectangle"  (position 0 0 0)  (position dsub wtot 0) )
(sdedr:define-refinement-size "global" xref yref 0 (/ xref 2) (/ yref 2) 0)
(sdedr:define-refinement-placement "global" "global" "global" )

;; Save generated model
(display "save structure...\n")
(sde:build-mesh (string-append "n" myNode "_msh"))
(display "End structure generation\n")
