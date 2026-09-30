; Reinitializing SDE 
(sde:clear)
; set coordinate system up direction 
(sde:set-process-up-direction "-x")

; old replaces new
(sdegeo:set-default-boolean "BAB")

;----------------------------------------------------------------------;
(define Zbox  0.090)
(define Ybox  0.090)
(define Xbox  0.040)

(define Zcha  0.035)
(define Ycha  0.010)
(define Xcha  -0.020)

(define Zmas  Zcha)
(define Ymas  Ycha)
(define Xmas  (- Xcha 0.015))

(define Zsd  0.070)
(define Ysd  0.070)
(define Xsd  -0.040)

(define Zsdm  Zcha)
(define Ysdm  Ysd)
(define Xsdm  (- Xsd 0.030))

(define Zgox  Zcha)
(define Ygox  (+ Ycha 0.002))
(define Xgox  (- Xmas 0.002))

(define Zspa  0.015)
(define Yspa  Ysd)
(define Xspa  (+ Xsdm 0.005))

(define Zpol  0.045)
(define Ypol  0.060)
(define Xpol  -0.080)

;----------------------------------------------------------------------;

;--- BOX
(sdegeo:create-cuboid 
	(position 0 0 Zbox) (position Xbox Ybox 0)  
	"Oxide" "BOX"
)

;--- Channel
(sdegeo:create-cuboid 
	(position 0 0 0)  (position Xcha Ycha Zcha)  
	"Silicon" "Channel"
)


;--- Channel Mask
(sdegeo:create-cuboid 
	(position Xcha 0 0) (position Xmas Ymas Zmas)  
	"Nitride" "ChMask"
)

;--- Source/Drain 
(sdegeo:create-cuboid 
	(position 0 0 Zcha)  (position Xsd Ysd Zsd)  
	"Silicon" "SourceDrain"
)

;--- Source/Drain Mask
(sdegeo:create-cuboid 
	(position Xcha 0 Zsd) (position Xsdm Ysdm Zsdm)  
	"Nitride" "SDMask"
)
;??

;--- Gate Oxide
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid 
	(position 0 0 0) (position Xgox Ygox Zgox)  
	"Oxide" "Gox"
)

;--- Spacer with rounding
(sdegeo:create-cuboid 
	(position 0 0 Zcha) (position Xspa Yspa Zspa)  
	"Nitride" "Spacer"
)
(define fillet-radius (* 0.75 (- Zcha Zspa)) )

(sdegeo:fillet 
	(find-edge-id (position Xspa (* 0.5 Yspa) Zspa))
	fillet-radius
)
;okay

;--- Poly Gate
(sdegeo:create-cuboid 
	(position 0 0 0) (position Xpol Ypol Zpol)  
	"PolySilicon" "Gate"
)
;okay


;--- Gate contact:
(sdegeo:set-contact (find-face-id (position Xpol (* 0.5 Ypol) (* 0.5 Zpol))) "gate")

;--- Substrate contact:
(sdegeo:set-contact (find-face-id (position Xbox (* 0.5 Ybox) (* 0.5 Zbox))) "sub")  

;--- Delete Source/Drain Mask
(define SDMaskID (find-body-id (position (* 0.5 (+ Xcha Xsdm))
                                              (* 0.5 Ysdm)
                                              (* 0.5 (+ Zsd Zsdm)) ) ))
(sdegeo:delete-region SDMaskID)

(sdegeo:reflect (get-body-list) 
 (position 0 0 0) (gvector 0 0 -1) #t)

(define Zdrain (+ Zcha (* 0.5 (- Zsd Zsdm)            ) ))
(define Zsource (* -1.0 Zdrain))  

;--- Assign drain contact
(sdegeo:set-contact (find-face-id (position Xsd (* 0.5 Ysd)  Zdrain   )) "drain")  

;--- Assign source contact
(sdegeo:set-contact (find-face-id (position Xsd (* 0.5 Ysd) Zsource   )) "source")  


;--- Constant BG doping in all of Si
(sdedr:define-constant-profile "Boron_BG" "BoronActiveConcentration" 1e16)
(sdedr:define-constant-profile-material "Boron_BG_PL" "Boron_BG" "Silicon")

;--- Constant BG doping in all of Poly
(sdedr:define-constant-profile "PolyDop" "ArsenicActiveConcentration" 1e20)
(sdedr:define-constant-profile-material "Poly_PL" "PolyDop" "PolySilicon")

;--- Constant doping is S/D region
(sdedr:define-constant-profile "SD" "ArsenicActiveConcentration" 5e19)
(sdedr:define-constant-profile-region "constSource" "SD" "SourceDrain")
(sdedr:define-constant-profile-region "constDrain"  "SD" "SourceDrain.z")

; Let S/D a bit "diffuse" into the channel

(sdedr:define-gaussian-profile "SDChannel"
       "ArsenicActiveConcentration" "PeakPos" 0.0 "PeakVal" 5E19
       "ValueAtDepth" 1E16 "Depth" 0.0075 "Gauss" "Factor" 0.0)

(sdedr:define-refinement-window "Channelright"
       "Rectangle" (position 0.0 0.0 Zcha) (position Xcha Ycha Zcha) )

(sdedr:define-analytical-profile-placement "SDright"
       "SDChannel" "Channelright" "Negative" "NoReplace" "Eval")

(sdedr:define-refinement-window "Channelleft"
       "Rectangle" (position 0.0 0.0 (* -1.0 Zcha) ) (position Xcha Ycha (* -1.0 Zcha)) )

(sdedr:define-analytical-profile-placement "SDleft"
       "SDChannel" "Channelleft" "Positive" "NoReplace" "Eval")



;--- Meshing Strategy 
(sdedr:define-refinement-size "Si_Mesh" 0.010 0.010 0.010 0.005 0.005 0.005)
(sdedr:define-refinement-material "Si_Mesh_PL" "Si_Mesh" "Silicon" )

(sdedr:define-refinement-size "Po_Mesh" 0.010 0.010 0.010 0.005 0.005 0.005)
(sdedr:define-refinement-material "Po_Mesh_PL" "Po_Mesh" "PolySilicon" )

(sdedr:define-refinement-size "Cha_Mesh" 0.0025 0.0025 0.0025 0.0005 0.002 0.002 )
(sdedr:define-refinement-function "Cha_Mesh" 
  "DopingConcentration" "MaxTransDiff" 1)

(sdegeo:bool-unite 
 (list 
  (car (find-body-id   (position (*  0.5 Xcha) (* 0.5 Ycha) (* 0.5 Zcha) )))
  (car (find-body-id   (position (*  0.5 Xcha) (* 0.5 Ycha) (* -0.5 Zcha) )))
 )
)   
 
(sde:add-material  
   (find-body-id   (position (* 0.5 Xcha) (* 0.5 Ycha) 0.0 ))
   "Silicon" "Channel")

(sdedr:define-refinement-region "Cha_Mesh_PL" "Cha_Mesh" "Channel" )


;--- Save BND and CMD and rescale to um
(sde:build-mesh "n@node@")
