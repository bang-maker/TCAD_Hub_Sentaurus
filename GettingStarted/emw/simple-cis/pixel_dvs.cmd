# load default #seth definitions during preprocessing
#includeext "pixel_var.txt"
# label all extracted variable as hidden
#seth zmin x
#seth zmax x
#seth zmin_poly x
#seth zmax_poly x

;;------------------------------------------------------------------------------
(sde:display-std "init") ; {{{
(sde:clear)
(define echo-executed-commands #f) ; switch off echoing commands in log file. 
(sde:set-process-up-direction "+z")
; }}}

;;------------------------------------------------------------------------------
(sde:display-std "create structure") ; {{{
(sdegeo:create-cuboid
  (position 0 0 0) 
  (position @w_pixel@ @w_pixel@ (- @t_sub@))
  "Silicon" "sub")
;---
(sdegeo:create-cuboid
  (position (/ (- @w_pixel@ @w_poly@) 2) (/ (- @w_pixel@ @w_poly@) 2) @t_poly@) 
  (position (/ (+ @w_pixel@ @w_poly@) 2) (/ (+ @w_pixel@ @w_poly@) 2) 0)
  "PolySilicon" "poly")

#if [string match -nocase "*reflector*" "@geo@"]
(sde:display-std "  rear reflector") ; {{{
;---
(sdegeo:create-cuboid
  (position (/ (- @w_pixel@ @w_ref@) 2) (/ (- @w_pixel@ @w_ref@) 2) @t_ref@) 
  (position (/ (+ @w_pixel@ @w_ref@) 2) (/ (+ @w_pixel@ @w_ref@) 2) 0)
  "Gas" "rearReflector")
; }}}
#endif
; }}}

;;------------------------------------------------------------------------------
(sde:display-std "extract coordinates") ; {{{
(define zmin (sde:min-z (get-body-list)))
(sde:ft_scalar "zmin " zmin)
;---
(define zmax (sde:max-z (get-body-list)))
(sde:ft_scalar "zmax " zmax)
;---
(define zmin_poly (sde:min-z (find-region-id "poly")))
(sde:ft_scalar "zmin_poly " zmin_poly)
;---
(define zmax_poly (sde:max-z (find-region-id "poly")))
(sde:ft_scalar "zmax_poly " zmax_poly)
; }}}

;;------------------------------------------------------------------------------
(sde:display-std "save boundary") ; {{{
(sde:save-model "n@node@_dvs")
; }}}
# :folding=explicit: 