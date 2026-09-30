#setdep @node|SDFT@
#setdep @node|MDFT@

if {![info exists runVisualizerNodesTogether]||[llength $nodelist] > 1} {
  puts "To see some curves select a single Sentaurus Visual node and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}
load_library extract

set n @node@
#- Find Hdom HB file names of interest of mode (SDFT,MDFT) simulation. 
set fNames(SDFT) [lrange [lsort [glob "@[relpath pn_n@node|SDFT@_*_Hdom_des.plt]@"]] 2 end]
set fNames(MDFT) [lrange [lsort [glob "@[relpath pn_n@node|MDFT@_*_Hdom_des.plt]@"]] 2 end]

if {[llength [list_plots]] == 0} {
  create_plot -1d -name "VaIa"
  select_plots {"VaIa"}
  set_plot_prop -hide_title
  set_legend_prop -label_font_family arial -label_font_size 14 -location "bottom_right"
  set_axis_prop -title_font_size 20 -type log
}

foreach mode {SDFT MDFT} {
  echo "mode $mode"
  set Va [list]
  for {set i 0} {$i <= 4} {incr i} {
    set Ia($i) [list]
  }
  
  echo "Extract amplitudes of harmonics"
  foreach fn $fNames($mode) {
    load_file $fn -name DS
    set hs   [get_variable_data "Hindex"             -dataset DS]
    set vas  [get_variable_data "Mag(V_in(anode))"   -dataset DS]
    set ias  [get_variable_data "Mag(I_t(anode))"    -dataset DS]
    ext::ExtractValue -out va  -x $hs -y $vas -xo 1 -occurrence 1 -name "noprint"
    lappend Va $va
    for {set i 0} {$i <= 4} {incr i} {
      ext::ExtractValue -out ia -x $hs -y $ias -xo $i -occurrence 1 -name "noprint"
      lappend Ia($i) $ia
    }
    remove_datasets DS
  }

  echo "create variables"
  create_variable -name "va"  -dataset "ds($n,$mode)" -values $Va
  for {set i 0} {$i <= 4} {incr i} {
    create_variable -name "ia$i" -dataset "ds($n,$mode)" -values $Ia($i)
    create_curve -name "vi($n,$mode,$i)" -dataset "ds($n,$mode)" -axisX va -axisY ia$i
    set_curve_prop "vi($n,$mode,$i)" -label "$mode: I<sub>a$i</sub>(V<sub>a</sub>) $legend"
  }
}

for {set i 0} {$i <= 4} {incr i} {
  set_curve_prop "vi($n,SDFT,$i)" -line_width 3 
  set_curve_prop "vi($n,MDFT,$i)" -show_markers -markers_type diamond -line_width 2 -hide_line
}
                                                             
set_axis_prop -axis x -title {Va [V]} -min 0.002 -min_fixed -max 1.1 -max_fixed
set_axis_prop -axis y -title {Ia [A]} -label_format scientific
if { @Vdc@ > 0 } {
  set_axis_prop -axis y -min 1e-10 -min_fixed -max 1 -max_fixed
} else {
  set_axis_prop -axis y -min 1e-18 -min_fixed -max 2e-10 -max_fixed
}
