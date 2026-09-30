load_library extract
lib::SetInfoDef 1

set Types [list nMOS nMOS nMOS nMOS nMOS nMOS nMOS nMOS \
    pMOS pMOS pMOS pMOS pMOS pMOS pMOS pMOS]
set Lgs [list 0.090 0.090 0.045 0.045 0.130 0.130 0.065 0.065 \
    0.065 0.065 0.045 0.045 0.130 0.130 0.090 0.090]
set Stress [list no yes no yes no yes no yes \
    no yes no yes no yes no yes]
set Vtgms [list 0.424 0.0374 0.313 0.263 0.414 0.364 0.408 0.358 \
    -0.344 -0.294 -0.232 -0.182 x x -0.374 -0.324]

# Ex 1: Get Vt roll-off curve for PMOS 
# Filter using one condition
set Conditions(Target,1) "pMOS"
set Conditions(Values,1) $Types
ext::FilterTable -out LgVt -x $Lgs -y $Vtgms -conditions Conditions -ncond 1    
puts "Lg: $LgVt(X)"
puts "Vtgm: $LgVt(Y)"
#-> Lg: 0.045 0.045 0.065 0.065 0.090 0.090
#-> Vtgm: -0.232 -0.182 -0.344 -0.294 -0.374 -0.324

# Ex 2: Plot Vt roll-off curve for PMOS under stress 
# Filter using two conditions
set Conditions(Target,1) "pMOS"
set Conditions(Values,1) $Types
set Conditions(Target,2) "yes"
set Conditions(Values,2) $Stress
ext::FilterTable -out LgVt -x $Lgs -y $Vtgms -conditions Conditions -ncond 2

puts "Lg: $LgVt(X)"
puts "Vtgm: $LgVt(Y)"
#-> Lg: 0.045 0.065 0.090
#-> Vtgm: -0.182 -0.294 -0.324

# Create variables with filtered values
create_variable -name Lg -dataset VtgmLg -values $LgVt(X)
create_variable -name Vtgm -dataset VtgmLg -values $LgVt(Y)
create_plot -1d -name Plot_VtRollOff
create_curve -name VtRollOff -dataset VtgmLg -axisX "Lg" -axisY "Vtgm"

set_curve_prop VtRollOff -label "VtRollOff (pMOS under stress)" \
	-color red -line_style solid -line_width 3 -show_markers -markers_size 7

# Annotate plot
set_plot_prop -title "Roll-off Curve" -title_font_size 20 -show_grid 
set_axis_prop -axis x -title {Lg [<greek>m</greek>m]} \
    -title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {Vtgm [V]} \
    -title_font_size 16 -label_font_size 14 -type linear

set_legend_prop -label_font_size 12 -location top_right -label_font_att bold		