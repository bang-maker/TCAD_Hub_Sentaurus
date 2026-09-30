(define size (sqrt @area@))

(sdegeo:create-cuboid (position 0 0 0) (position 1 size size) "Silicon" "SUB")

(sdegeo:set-contact (find-face-id (position 0 (* 0.5 size) (* 0.5 size) )) "C1")
(sdegeo:set-contact (find-face-id (position 1 (* 0.5 size) (* 0.5 size) )) "C2")
	
; Creating a refinement specification for a given material
(define MNAME "Silicon")
(sdedr:define-refinement-size (string-append "RS." MNAME) 
	0.1 (* 0.25 size) (* 0.25 size)   
	0.01 0.01 0.01
)
(sdedr:define-refinement-material (string-append "RP." MNAME) (string-append "RS." MNAME) MNAME)

; Constant doping profile in a given material
(define NAME "BG")
(sdedr:define-constant-profile (string-append "DC." NAME) "PhosphorusActiveConcentration" 8.17733e19)
(sdedr:define-constant-profile-material (string-append "CPM." NAME) (string-append "DC." NAME) "Silicon" )

(sde:build-mesh "n@node@_msh")
