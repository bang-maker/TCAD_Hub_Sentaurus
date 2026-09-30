; Reinitializing SDE 
(sde:clear)
; default coordinate system up direction is "-x"
;(sde:set-process-up-direction "-x")

; Define emulation Domain and substrate
(sdepe:define-pe-domain (list 0 -80 80 80))
(sdepe:add-substrate "material" "Silicon" "thickness" 40 )

; Deposit buried oxide layer
(sdepe:depo "material" "Oxide" "thickness" 40)

; Deposit silicon layer and hard mask
(sdepe:depo "material" "Silicon" "thickness" 20)
(sdepe:depo "material" "Insulator1" "thickness" 10)

; Pattered poly silicon layer and deposit nitride
(sdepe:generate-mask "CHA" (list (list 0 10 80 80)))
(sdepe:pattern "mask" "CHA" "polarity" "light" "material" "PolySi" "thickness" 20 "type" "aniso")
(sdepe:depo "material" "Nitride" "thickness" 20)

; Etch nitride and strip poly silicon
(sdepe:etch-material "material" "Nitride" "depth" 20)
(sdepe:remove "material" "PolySi")

; Etch hard mask and silicon and strip nitride mask
(sdepe:etch-material "material" "Insulator1" "depth" 10)
(sdepe:etch-material "material" "Silicon" "depth" 20)
(sdepe:remove "material" "Nitride")

; Pattern nitride mask and deposit silicon
(sdepe:generate-mask "SD" (list (list 0 -80 30 80)))
(sdepe:pattern "mask" "SD" "polarity" "light" "material" "Nitride" "thickness" 120 "type" "aniso")
(sdepe:depo "material" "Silicon" "thickness" 60 "type" "aniso")

; Fill and polish
(sdepe:fill-device "material" "Insulator1")
(sdepe:polish-device "thickness" 100)

; Strip nitride and deposit gate oxide
(sdepe:remove "material" "Nitride")
(sdepe:depo "material" "Oxide" "thickness" 2)

; Deposit nitride (with rounding) 
(sdepe:depo "material" "Nitride" "thickness" 15 "vexity" "convex" "radius" 15 "blend-global")

; Etch nitride spacer
(sdepe:etch-material "material" "Nitride" "depth" 50)

; Deposit (patterned) poly silicon gate
(sdepe:generate-mask "POL" (list (list 0 -80 60 40)))
(sdepe:pattern "mask" "POL" "polarity" "light" "material" "PolySi" "thickness" 80 "type" "aniso")

; Reflect structure
(sdegeo:reflect (get-body-list) (position 0 0 0) (gvector 0 -1 0) #t)

;----------------------------------------------------------
; Saving
;---------------------------------------------------
(sde:save-model "n@node@_finfet_procem")

