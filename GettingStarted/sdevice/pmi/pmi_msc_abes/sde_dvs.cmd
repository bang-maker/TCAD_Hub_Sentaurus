(sde:clear)
(define tiny 1e-5)

(define Wpcm 0.002)
(define Hpcm 0.010)
(define Wall 0.016)
(define Hall 0.020)

(define hWpcm (/ Wpcm 2))
(define hHpcm (/ Hpcm 2))
(define hWall (/ Wall 2))
(define hHall (/ Hall 2))

(sdegeo:create-rectangle (position     0 0 0) (position hHall hWall 0) "Oxide" "isolation")
(sdegeo:create-rectangle (position     0 0 0) (position hHpcm hWpcm 0) "ChalcogenideC" "pcm")
(sdegeo:create-rectangle (position hHpcm 0 0) (position hHall hWpcm 0) "Tungsten" "botmetal")

(sdegeo:set-contact (find-edge-id (position    hHall  tiny 0)) "bottom")

(define DX (/ Hall 31))
(define dx (/ DX 2))
(define DY (/ Wpcm 8))
(define dy (/ DY 2))
(define DXX (* DX 4))
(define DYY (* DY 4))
(sdedr:define-refinement-size "RED_pcm" DX DY 1 dx dy 1 )
(sdedr:define-refinement-placement "REP_pcm" "RED_pcm" (list "region" "pcm" ) )

(sdedr:define-refinement-size "RED_metal" DXX DYY 1 dx dy 1 )
(sdedr:define-refinement-placement "REP_metal" "RED_metal" (list "material" "Tungsten" ) )
(sdedr:define-refinement-function  "RED_metal" "MaxLenInt" "Tungsten" "ChalcogenideC" dx 1.4 )

(sdedr:define-refinement-size "RED_oxide" DXX DYY 1 dx dy 1 )
(sdedr:define-refinement-placement "REP_oxide" "RED_oxide" (list "material" "Oxide" ) )
(sdedr:define-refinement-function  "RED_oxide" "MaxLenInt" "Oxide" "ChalcogenideC"  DY 1.4 )

(sde:build-mesh "" "n@node@_qua")

(system:command "tdx -mtt -y  n@node@_qua_msh  n@node@_half_msh")
(system:command "tdx -mtt -x  -ren bottom=top n@node@_half_msh n@node@_msh")
(system:command "rm  n@node@_qua_bnd* n@node@_qua_msh* n@node@_half_bnd* n@node@_half_msh*")