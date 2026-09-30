#setdep @previous@
#if "@Type@" == "nmos"
#seth field "eDensity"
#else 
#seth field "hDensity"
#endif
set mydata [load_file @[relpath n@node|Compute_Density_Mobility@_Vg_0.60_epm.tdr]@ -fod]
set myplot1 [create_plot -dataset $mydata]
select_plots $myplot1
set_axis_prop -plot $myplot1 -axis x -title "Width (um)" 
set_axis_prop -plot $myplot1 -axis y -title "Height (um)" 
set_axis_prop -plot $myplot1 -axis x -label_font_family arial -label_font_factor 1
set_axis_prop -plot $myplot1 -axis y -label_font_family arial -label_font_factor 1

set_field_prop !(puts -nonewline @field@)! -plot $myplot1 -show_bands
set_field_prop !(puts -nonewline @field@)! -plot $myplot1 -show_bands

set_field_prop !(puts -nonewline @field@)! -plot $myplot1 -min 2e+12 -min_fixed
set_field_prop !(puts -nonewline @field@)! -plot $myplot1 -max 2e20 -max_fixed

set_region_prop {ox1} -plot $myplot1 -color #a0a0a4
set_region_prop {ox2} -plot $myplot1 -color #a0a0a4
set_region_prop {ox3} -plot $myplot1 -color #a0a0a4
set_region_prop {ox4} -plot $myplot1 -color #a0a0a4

set_region_prop {hf1} -plot $myplot1 -color #800080
set_region_prop {hf2} -plot $myplot1 -color #800080
set_region_prop {hf3} -plot $myplot1 -color #800080
set_region_prop {hf4} -plot $myplot1 -color #800080

set_legend_prop -plot $myplot1 -label_font_family arial -title_font_factor 2 -label_font_factor 2 -precision 0


set mydata [load_file @[relpath n@node|Compute_Density_Mobility@_Vg_0.90_epm.tdr]@ -fod]
set myplot2 [create_plot -dataset $mydata]
select_plots $myplot2
set_axis_prop -plot $myplot2 -axis x -title "Width (um)" 
set_axis_prop -plot $myplot2 -axis y -title "Height (um)" 
set_axis_prop -plot $myplot2 -axis x -label_font_family arial -label_font_factor 1
set_axis_prop -plot $myplot2 -axis y -label_font_family arial -label_font_factor 1

set_field_prop !(puts -nonewline @field@)! -plot $myplot2 -show_bands
set_field_prop !(puts -nonewline @field@)! -plot $myplot2 -min 2e+12 -min_fixed
set_field_prop !(puts -nonewline @field@)! -plot $myplot2 -max 2e20 -max_fixed

set_region_prop {ox1} -plot $myplot2 -color #a0a0a4
set_region_prop {ox2} -plot $myplot2 -color #a0a0a4
set_region_prop {ox3} -plot $myplot2 -color #a0a0a4
set_region_prop {ox4} -plot $myplot2 -color #a0a0a4

set_region_prop {hf1} -plot $myplot2 -color #800080
set_region_prop {hf2} -plot $myplot2 -color #800080
set_region_prop {hf3} -plot $myplot2 -color #800080
set_region_prop {hf4} -plot $myplot2 -color #800080


link_plots [ select_plots [list  $myplot1 $myplot2 ]]


set C1 [create_cutline -plot $myplot1 -type x -at 0]
set myplot3 [create_plot -dataset $C1 -1d]
select_plots $myplot3
create_curve -axisX Y -axisY !(puts -nonewline @field@)! -dataset {C1(n@node|Compute_Density_Mobility@_Vg_0.60_epm) C1(n@node|Compute_Density_Mobility@_Vg_0.90_epm)} -plot $myplot3
set_axis_prop -plot $myplot3 -axis y -type log
zoom_plot -plot $myplot3 -window {!(puts -nonewline "[expr -@H@/2 -1e-3]")! 2e+17 !(puts -nonewline "[expr @H@/2 +1e-3]")! 1.5e+21}
set_curve_prop {Curve_1} -plot $myplot3 -label "!(puts -nonewline @field@)! at |VG|=0.6"
set_curve_prop {Curve_2} -plot $myplot3 -label "!(puts -nonewline @field@)! at |VG|=0.9"
set_axis_prop -plot $myplot3 -axis x -title "Along Height (um)" 
set_axis_prop -plot $myplot3 -axis y -title "!(puts -nonewline @field@)! (/cm3)" 

set C2 [create_cutline -plot $myplot1 -type y -at 0]
set myplot4 [create_plot -dataset $C2 -1d]
select_plots $myplot4
create_curve -axisX X -axisY !(puts -nonewline @field@)! -dataset {C2(n@node|Compute_Density_Mobility@_Vg_0.60_epm) C2(n@node|Compute_Density_Mobility@_Vg_0.90_epm)}  -plot $myplot4
set_axis_prop -plot $myplot4 -axis y -type log

zoom_plot -plot $myplot4 -window {!(puts -nonewline "[expr -@W@/2 -1e-3]")! 2e+17 !(puts -nonewline "[expr @W@/2 +1e-3]")! 2e20}
set_curve_prop {Curve_1} -plot $myplot4 -label "!(puts -nonewline @field@)! at |VG|=0.6"
set_curve_prop {Curve_2} -plot $myplot4 -label "!(puts -nonewline @field@)! at |VG|=0.9"
set_axis_prop -plot $myplot4 -axis x -title "Along Width (um)" 
set_axis_prop -plot $myplot4 -axis y -title "!(puts -nonewline @field@)! (/cm3)" 

