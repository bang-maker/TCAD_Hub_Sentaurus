set plotlist ""
set datalist ""

set dir "@pwd@/fdsoi_movie"
set filelist [lsort [glob -tails -dir $dir IdVgSat__*_des.tdr]]

puts ""
puts "[llength $filelist] files matching the pattern \"IdVgSat__*_des.tdr\" under the directory: $dir"
puts "filelist = $filelist"
puts ""

set_window_full -on
windows_style -style max

foreach file  $filelist {
  set data [file rootname $file]
  set datalist "$datalist $data"
  
  puts -nonewline "loading data= $data ... "; flush stdout
  load_file $dir/$file -name $data
  puts  "done"
  
  set plotname "Plot_${data}"
  set plotlist "$plotlist $plotname"
  
  puts -nonewline "creating plot $plotname ... "; flush stdout
  create_plot -name $plotname -dataset $data
  puts  "done"
}
puts ""

################################################################################################
puts "STARTING MOVIE FOR eCurrentDensity ..."

link_plots $plotlist -unlink

puts -nonewline "Plot properties "; flush stdout

set i 1
foreach plotname $plotlist  data $datalist {
  puts -nonewline "$i "; flush stdout
  
  select_plots $plotname
  
  set title "Vd=0.9V"
  set_plot_prop -plot $plotname -title $title -title_font_family arial -title_font_factor 2 -title_font_color #000000 -title_font_att bold
  
  set_material_prop Silicon -plot $plotname -geom $data -show_bulk
  
  set_field_prop -plot $plotname -geom $data Abs(eCurrentDensity-V) -show_bands -min 10 -min_fixed -max 1e8 -max_fixed -levels 41
  set_field_prop -plot $plotname -geom $data ElectrostaticPotential -show -levels 41 -min -0.5 -min_fixed -max 1.5 -max_fixed
  
  zoom_plot -plot $plotname -window {-0.03 -0.040 0.02 0.045}
  set_legend_prop -plot $plotname -position {0.19 0.45} -size {0.51 0.33} -precision 1 -orientation horizontal -show_background -nof_labels 8
  move_plot -plot $plotname -position {0 0}
  
  incr i
}
puts "done"

link_plots $plotlist 
link_plots $plotlist -unlink

start_movie -resolution 1300x657
set framelist ""

puts -nonewline "creating frames "; flush stdout
set i 1
foreach plotname $plotlist {
  puts -nonewline "$i "; flush stdout
  select_plots $plotname
  set framename "Frame_$plotname"
  set framelist "$framelist $framename"
  add_frame -plot $plotname -name $framename
  incr i
}
puts "done"

puts -nonewline "Creating GIF movie ... "; flush stdout

export_movie -filename n@node@_eCurrentDensity.gif -frames "$framelist" -frame_duration 100 -overwrite
stop_movie
puts "MOVIE FOR eCurrentDensity DONE"