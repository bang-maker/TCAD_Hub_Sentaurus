#set wtot 0.2

(sde:clear)

;; width - width of the device [um]
(define wtot @wtot@)

(define regions     (list "plow" "phigh" "nhigh" "nlow"))
(define materials   (list "GaAs" "GaAs"  "GaAs"  "GaAs"))
(define dopings     (list -1e18  @pdop@  @ndop@  4e18))
(define heights     (list  0.1   @dp@    @dn@    0.1))

(display "-------------------------------------------------------------------\n")
(display "Defining structure generation procedures that are called later\n")
(display " ------------------------------------------------------------------\n")

;; create a constant region-based doping profile where negative doping = p-type!!
(define layer:create-doping
  (lambda ( region doping )
    (if (< doping 0) (define dopingtype "BoronActiveConcentration")
      (define dopingtype "ArsenicActiveConcentration") 
    )
    (define Doping_Profilename (string-append "Doping_prof_" region))
    (define Doping_Placementname (string-append "Doping_place_" region))
    (sdedr:define-constant-profile Doping_Profilename dopingtype doping)
    (sdedr:define-constant-profile-region Doping_Placementname Doping_Profilename region)   
  )
);;end procedure

;; ----------------------------------------
(display "create structure... \n")

(display "Creating layer stack and doping placement...\n")
(define ref (- (+ 0.1 @dp@)))
(for-each
 (lambda (region material height doping)  ; Names of local variables
   (begin                         ; Body of the loop
     (sdegeo:create-rectangle     
        (position	ref 0.0 0.0)
        (position	(+ ref height) wtot 0.0) material region )
     (layer:create-doping region doping)	; define doping profile   
     (set! ref (+ ref height))
   ) ; end begin
 ) regions materials heights dopings     ; Lists defined above
)

; Extract the (x,y) min & max coordinates
(define xmin (position:x (car (bbox (get-body-list)))))
(define xmax (position:x (cdr (bbox (get-body-list)))))
(define ymin (position:y (car (bbox (get-body-list)))))
(define ymax (position:y (cdr (bbox (get-body-list)))))

;; ----------------------------------------
(display "define contacts... \n")
;;-- topcontact: anode
(sdegeo:define-contact-set "anode" 4  (color:rgb 0 1 0 ) "##" )
(sdegeo:define-2d-contact (find-edge-id (position xmin (/ wtot 2)	0)) "anode")
;;-- bottom contact: cathode
(sdegeo:define-contact-set "cathode" 4  (color:rgb 1 0 0 ) "##" )
(sdegeo:define-2d-contact (find-edge-id (position xmax (/ wtot 2)	0)) "cathode")

;; ----------------------------------------
(display "add refinements ... \n")

(display "add global refinement ... \n")

(sdedr:define-refeval-window "Ref_global"  "Rectangle"
  (position xmin ymin 0) (position xmax ymax 0))
  (sdedr:define-refinement-size "Ref_global" xmax (/ wtot 2) 0.0 xmax (/ wtot 2) 0.0)
(sdedr:define-refinement-placement "Ref_global" "Ref_global" "Ref_global")

(display "add refinements in plow ... \n")
(sdedr:define-refeval-window "Ref_plow" "Rectangle"
  (position 0.0 0.0 0.0) (position 0.4 wtot 0.0))
(sdedr:define-multibox-size "mbox_plow_down" 0.4 wtot 0.0 
  0.001 wtot 0.0     -1.5 1.0 1.0)
(sdedr:define-multibox-placement "mbox_plow_down" "mbox_plow_down" "Ref_plow")

(sdedr:define-refinement-size "Ref_plow" 0.05 wtot 0.0 0.05 wtot 0.0)
(sdedr:define-refinement-region "Ref_plow" "Ref_plow" "plow")

(display "add refinements in phigh ... \n")
(sdedr:define-refinement-size "Ref_phigh" 0.0005 wtot 0.0 0.0005 wtot 0.0)
(sdedr:define-refinement-region "Ref_phigh" "Ref_phigh" "phigh")

(display "add refinements in nhigh ... \n")
(sdedr:define-refinement-size "Ref_nhigh" 0.0005 wtot 0.0 0.0005 wtot 0.0)
(sdedr:define-refinement-region "Ref_nhigh" "Ref_nhigh" "nhigh")

(display "add refinements in nlow ... \n")
(sdedr:define-refeval-window "Ref_nlow" "Rectangle"
  (position 0.453 0.0 0.0) (position 0.853 wtot 0.0))
(sdedr:define-multibox-size "mbox_nlow_up" 0.4 wtot 0.0
  0.001 wtot 0.0     1.5 1.0  1.0)
(sdedr:define-multibox-placement "mbox_nlow_up" "mbox_nlow_up" "Ref_nlow")

(sdedr:define-refinement-size "Ref_nlow" 0.05 wtot 0.0 0.05 wtot 0.0)
(sdedr:define-refinement-region "Ref_nlow" "Ref_nlow" "nlow")

;; ----------------------------------------
(display "build mesh... \n")
(sde:build-mesh "n@node@_msh")

(display "done.\n")

(display "SDE completed sucessfully. Have a nice day.")(newline)

