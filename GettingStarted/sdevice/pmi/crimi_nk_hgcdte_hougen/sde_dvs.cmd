(sde:clear)
(display "define constants... \n")
;;geometry
(define wtot 1); um
;; refinements
(define xref 0.2)
(define yref 0.5)
;; others
(define myNode "@node@")

;; ----------------------------------------
(display "create structure... \n")

(display "  layer1")(newline)
(sdegeo:create-rectangle (position 0 0 0) (position 1 wtot 0) "HgCdTe" "layer1")

(display "  layer2")(newline)
(sdegeo:create-rectangle (position 1 0 0) (position 2 wtot 0) "HgCdTe" "layer2")
;; ----------------------------------------
(display "Define Contacts... \n")
(display "  nContact... \n")
(sdegeo:define-contact-set "nContact" 4  (color:rgb 0 1 0 ) "##" )
(sdegeo:set-contact (find-edge-id (position 0 0.5 0)) "nContact")
(display "  pContact... \n")
(sdegeo:define-contact-set "pContact" 4  (color:rgb 0 1 0 ) "##" )
(sdegeo:set-contact (find-edge-id (position  2 0.5 0)) "pContact")
(sde:refresh)

;;----------------------------------------
(display "put dummy doping\n")
(sdedr:define-refeval-window "default" "Rectangle"  (position 0 0 0)  (position 2 wtot 0) )
(sdedr:define-constant-profile "ConstantProfileDefinition_1" "BoronActiveConcentration" 1e13)
(sdedr:define-constant-profile-placement "ConstantProfilePlacement_1" "ConstantProfileDefinition_1" "default")

;;----------------------------------------
(display "put mole profile\n")
(sdedr:define-analytical-profile-placement "mole_2" "mole_2"
	 "mole_2" "Both" "NoReplace" "Eval" "layer2" 0. "region")
(sdedr:define-analytical-profile "mole_2" "xMoleFraction"
  "" "0.1*(1-x)+0.1"  0. "General")

;; ----------------------------------------
(display "add refinements ... \n")
;; global refinement
(sdedr:define-refeval-window "global" "Rectangle"  (position 0 0 0)  (position 3 wtot 0) )
(sdedr:define-refinement-size "global" xref yref 0 (/ xref 2) (/ yref 2) 0)
(sdedr:define-refinement-placement "global" "global" "global" )

;; Save generated model
(display "save structure...\n")
(sde:build-mesh (string-append "n" myNode "_msh"))
(display "End structure generation\n")

(display "SDE done. Have a nice day.")


