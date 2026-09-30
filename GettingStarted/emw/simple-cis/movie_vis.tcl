#setdep @node|emw@

#----
puts "user parameters"
set n @node@
set nemw @node|emw@
set cuts @movieCuts@ ;# defines multiple movie sets separated by _, e.g. Ex_Ey 
set filePattern "n${nemw}_%cut%_*_eml.tdr" ;# Plot file pattern, %cut% => Ex
set resolution      "400x600" ;# resolution of the gif
set framesPerSeconds 5        ;# frame rate in seconds
set plotRange {1 -1}          ;# 1=first, 2=second, -1=last, {1 -1} = all...
set plotSkip 1         ;# skip factor 1=each plot is used, 2=every second...

#----
# this procedure is called before frames are added, e.g. when ramping through states
proc init {} {
}

# addFrame is called with filename or stateindex. It shall create a single plot and format it.
# After that, the plot will be added to the frame buffer and any newly created datasets and plots will be removed. 
proc addFrame {fileOrStateIndex} {
  set MYDATA [load_file $fileOrStateIndex]
  set MYPLOT [create_plot -dataset $MYDATA]
  set_plot_prop -plot $MYPLOT -hide_title
  # set_plot_prop -plot $MYPLOT -hide_axes
  set_plot_prop -plot $MYPLOT -hide_legend
  switch -regexp $fileOrStateIndex {
    Ex {
      set_axis_prop -plot $MYPLOT -axis y -not_inverted
      set_axis_prop -plot $MYPLOT -axis x -title Y
      set_axis_prop -plot $MYPLOT -axis y -title Z
    }
    Ey {
      set_plot_prop -plot $MYPLOT -axes_interchanged
      set_axis_prop -plot $MYPLOT -axis x -not_inverted
      set_axis_prop -plot $MYPLOT -axis x -title Z
      set_axis_prop -plot $MYPLOT -axis y -title X
    }
    Ez {
    	set_axis_prop -plot $MYPLOT -axis y -not_inverted
    }
  }
  zoom_plot -plot $MYPLOT -reset
  set_field_prop -plot $MYPLOT -geom $MYDATA Abs(AbsElectricField-V) -show_bands
  set_field_prop -plot $MYPLOT -geom $MYDATA cplxRefIndex -show
}

#------------------------------------------------------------
# end user configuration part
#------------------------------------------------------------

#-----
# some functions
proc putsno {str} {
  puts -nonewline $str
  flush stdout
}

#-----
puts "Init plots "
init

foreach cut [split $cuts _] {
	if {"$cut" == ""} {continue}
  #-----              
  puts "get files for $cut"
  set fpattern [string map "%cut% $cut" $filePattern]
  set filelist [lsort [glob -nocomplain $fpattern]]
  puts "filelist: ([join $filelist ","])"
  # set movieFile "[string map "n${nemw} n$n _000_ _" [file rootname [lindex $filelist 0]]].gif"
  set movieFile "n@node@_${cut}.gif"
  
  #-----
  set plotlist {}
  # only run if we have some filelist to plot
  if {[llength $filelist] == 0} {
    puts "WARNING: No plot filelist available for movie generation!\n"
    puts "To create movie, re-run EMW toolstep with some movie filelist matching '$filePattern'"
    exit 0
  } elseif {[llength $filelist] == 1} {  
    #-----
    puts "Creating frames from states " 
    set istart [lindex $plotRange 0]
    set iend [lindex $plotRange 1]
    if {$iend < 0} {
      set iend [expr [llength [list_tdr_states]]+$iend+1]
    }
    for {set i $istart} {$i <= $iend} {incr i $plotSkip} {
      lappend plotlist $i
    }
  } else {
    puts "Creating frames from tdr filelist "
    set istart [expr [lindex $plotRange 0]-1]
    set iend [lindex $plotRange 1]
    if {$iend > 0} {
      set iend [expr $iend-1]
    } else {
      set iend [expr [llength $filelist]+$iend]
    }
    for {set i $istart} {$i <= $iend} {incr i $plotSkip} {
      if {$i < [llength $filelist]} {
        lappend plotlist [lindex $filelist $i]
      }
    }
  }
  # puts "plotlist: ([join $plotlist ","])"
  
  #-----
  putsno "Adding [llength $plotlist] frames to movie "
  if {$resolution != ""} {
    start_movie -resolution $resolution
  } else {
    start_movie 
  }
  set percentDone 0
  set percentIncr 10
  set percentSegment [expr max([llength $plotlist] / 10, 1)] ;# Compute segments for percentages
  if {$percentSegment == 1} {set percentIncr [expr 100 / [llength $plotlist]]}
  set i 0
  foreach fileOrIdx $plotlist {
    if { [expr $i % $percentSegment] == 0 } {
      putsno "$percentDone%..."
      incr percentDone $percentIncr
    }
    # save any existing plots and datasets
    set plist [list_plots]
    set dslist [list_datasets]
    render_mode -off;# zoom was reset prior to P-2019.03
    addFrame $fileOrIdx 
    render_mode -on 
    add_frame
    # remove any new plots and datasets
    foreach p [list_plots] {
      if {[lsearch $plist $p] < 0} {remove_plots [list $p]}
    }
    foreach ds [list_datasets] {
      if {[lsearch $dslist $ds] < 0} {remove_datasets [list $ds]}
    }
    incr i
  }
  if {$percentDone < 100.} {putsno "100%"}
  puts "\n"
  
  #-----
  puts "Creating GIF movie ... "
  export_movie -filename $movieFile -frame_duration [expr 100./$framesPerSeconds] -overwrite
  stop_movie
  puts "Movie written to $movieFile"
}
puts "DONE"
