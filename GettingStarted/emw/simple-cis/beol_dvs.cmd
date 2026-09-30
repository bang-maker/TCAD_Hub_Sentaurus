#setdep @previous@
# label all extracted variable as hidden
#seth zmax_Me1 x
#seth zmin_lens x
#seth zmax_lens x
#seth zmax x

;;------------------------------------------------------------------------------
;; header {{{
#header
(sde:clear)
(define echo-executed-commands #f) ; switch off echoing commands in log file.
(sde:set-process-up-direction "+z") ; set coordinate system orientation as z-up
#endheader
; }}} for jedit folding

;;------------------------------------------------------------------------------
(sde:display-std "load pixel and planarize it") ; {{{
(sde:open-model "n@previous@_dvs")
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid
  (position 0 0 @t_poly@)
  (position @w_pixel@ @w_pixel@ 0)
  "Oxide" "fill")
; }}} for jedit folding

;;------------------------------------------------------------------------------
#split @MeStack@ 
#if ![string match "*@MeStack@*" "0_"]
(sde:display-std "add metal stack") ; {{{ 
(sdepe:define-pe-domain 0 0 @w_pixel@ @w_pixel@)
(define a @w_pixel@)
(define b 0.1)
(define c (- @w_pixel@ b)) 
(sdepe:generate-mask "Me1" (list
  (list 0 0   0 a   a a   a 0) 
  (list b b   b c   c c   c b)
  ))
(sdepe:generate-mask "Me2" (list
  (list 0 0   b 0   b a   0 a) 
  (list a 0   c 0   c a   a a) 
  ))
(sdepe:depo "material" "Nitride" "thickness" @t_MeNi@ "iso" "region" "Ni1")
(sdepe:pattern "mask" "Me1" "polarity" "light" "type" "aniso" 
  "material" "Copper" "thickness" @t_Me1@ "region" "Me1")
(define Z (sde:max-z (get-body-list)))
(sde:ft_scalar  "zmax_Me1 " Z)
(sdepe:fill-device "material" "Oxide" "region" "Ox1")
; }}} for jedit folding
#endif

;;------------------------------------------------------------------------------
#split @Lens@ 
#if ![string match "*@Lens@*" "0_"]
(sde:display-std "add microlens") ; {{{
;;---
(sde:display-std "  pedestal") ; {{{
(sdegeo:set-default-boolean "BAB")
(sdegeo:create-cuboid
  (position 0 0 @t_pedestal@)
  (position @w_pixel@ @w_pixel@ 0)
  "Oxide" "fill")
; }}} for jedit folding
;;---
(sde:display-std "  lens") ; {{{
(define Z (sde:max-z (get-body-list)))
(sdegeo:create-sphere
  (position (/ @w_pixel@ 2) (/ @w_pixel@ 2) Z) 
  @r_Lens@ "Oxide" "lens")
(define Zlens (sde:min-z (find-region-id "lens")))
(sde:ft_scalar "zmin_lens " Zlens)
(define Zlens (sde:max-z (find-region-id "lens")))
(sde:ft_scalar "zmax_lens " Zlens)
; }}} for jedit folding
;;---
(sde:display-std "fill with air") ; {{{
(define Z (sde:max-z (get-body-list)))
(sdepe:fill-device "material" "Gas" "height" (+ Z @t_air@) "region" "gas")
(define Z (sde:max-z (get-body-list)))
(sde:ft_scalar "zmax " Z)
; }}} for jedit folding

;;---
(sde:display-std "save")
(sdeio:save-tdr-bnd (get-body-list) "@tdrboundary/o@")
; }}} for jedit folding
#endif

; :folding=explicit: