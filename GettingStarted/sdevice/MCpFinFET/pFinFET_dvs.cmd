(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "+z")

(define finhH 0.0172)
(define finhL 0.0750)
(define accL  0.1000)
(define acchH 0.0400)

(define OxTh  0.0013)
(define OxhH  0.0500)

(define GathL 0.0250)


(sdegeo:create-rectangle (position (- finhL) (- OxhH) 0) (position finhL OxhH 0) "Oxide" "Spacer")
(sdegeo:create-rectangle (position (- finhL) (- 0.0 finhH OxTh) 0) (position finhL (- 0.0 finhH) 0) "Oxide" "Tox")
(sdegeo:create-rectangle (position (- finhL) (+ 0.0 finhH OxTh) 0) (position finhL (+ 0.0 finhH) 0) "Oxide" "Box")

(sdegeo:create-rectangle (position (- finhL) (- finhH) 0) (position finhL finhH 0) "Silicon" "Active")
(sdegeo:create-polygon (list   (position (- 0.0 finhL) (- 0.0 finhH) 0)
        (position (- 0.0 finhL accL) (- 0.0 acchH) 0)
        (position (- 0.0 finhL accL) (+ 0.0 acchH) 0)
        (position (- 0.0 finhL) (+ 0.0 finhH) 0)
        (position (- 0.0 finhL) (- 0.0 finhH) 0) 
      ) "Silicon" "Sreg")
(sdegeo:create-polygon (list   (position (+ 0.0 finhL) (- 0.0 finhH) 0)
        (position (+ 0.0 finhL accL) (- 0.0 acchH) 0)
        (position (+ 0.0 finhL accL) (+ 0.0 acchH) 0)
        (position (+ 0.0 finhL) (+ 0.0 finhH) 0)
        (position (+ 0.0 finhL) (- 0.0 finhH) 0) 
      ) "Silicon" "Dreg")

(sdegeo:create-rectangle (position (- GathL) (- 0.0 finhH OxTh) 0) (position GathL (- 0.0 OxhH) 0) "Metal" "GateR")
(sdegeo:create-rectangle (position (- GathL) (+ 0.0 finhH OxTh) 0) (position GathL (+ 0.0 OxhH) 0) "Metal" "GateR")

(sdegeo:set-contact (find-material-id "Metal") "Gate" "remove")
(sdegeo:set-contact (list (car (find-edge-id (position (- 0.0 finhL accL) 0 0)))) "Source")
(sdegeo:set-contact (list (car (find-edge-id (position (+ 0.0 finhL accL) 0 0)))) "Drain")

;===============================================================================
;- define characteristic Gauss-Length and x.min and x.max for reference window
;- Source sided doping
(define l.char 0.009)
(define x.min (- 0.0 finhL accL))
(define x.max (* -4.5 l.char))
(define y.min  (- 0.0 OxhH 0.01))
(define y.max  (+ 0.0 OxhH 0.01))

(sdedr:define-refeval-window "REW1" "Rectangle" (position x.min y.min 0) (position x.max y.max 0))
(sdedr:define-analytical-profile-placement "APP1" "APD1" "REW1" "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "APD1" "BoronActiveConcentration" "PeakPos" 0  "PeakVal" 1e+20 "Length" l.char "Gauss"  "Factor" 1)

;- define  x.min and x.max for reference window Drain sided doping
(define x.max (+ 0.0 finhL accL))
(define x.min (* 4.5 l.char))
(define y.min  (- 0.0 OxhH 0.01))
(define y.max  (+ 0.0 OxhH 0.01))

(sdedr:define-refeval-window "REW2" "Rectangle" (position x.min y.min 0) (position x.max y.max 0))
(sdedr:define-analytical-profile-placement "APP2" "APD2" "REW2" "Both" "NoReplace" "Eval")
(sdedr:define-gaussian-profile "APD2" "BoronActiveConcentration" "PeakPos" 0  "PeakVal" 1e+20 "Length" l.char "Gauss"  "Factor" 1)

(sdedr:define-constant-profile "CPD1" "BoronActiveConcentration" 1e13)
(sdedr:define-constant-profile-material "CPP1" "CPD1" "Silicon")


;===============================================================================
;-- mesh refinements
(sdedr:define-refinement-size "RED1" 0.01 0.005 99 0.0005 0.0005 99 )
(sdedr:define-refinement-material "REP1" "RED1" "Silicon" )
(sdedr:define-refinement-function "RED1" "BoronActiveConcentration" "MaxTransDiff" 1)

(sdedr:define-refeval-window "RWMB1" "Rectangle" (position (- finhL) (- finhH) 0) (position finhL finhH 0))
(sdedr:define-multibox-size "MBD1" 0.005 0.002 1 0.005 0.0002 1 1 1.2 1 )
(sdedr:define-multibox-placement "MBP1" "MBD1" "RWMB1" )

(sdedr:define-refeval-window "RWMB2" "Rectangle" (position (- finhL) (- finhH) 0) (position finhL finhH 0))
(sdedr:define-multibox-size "MBD2" 0.005 0.002 1 0.005 0.0002 1 1 -1.2 1 )
(sdedr:define-multibox-placement "MBP2" "MBD2" "RWMB2" )

(sdesnmesh:axisaligned
	"fitInterfaces" #t
)

(sde:build-mesh "n@node@_msh")
