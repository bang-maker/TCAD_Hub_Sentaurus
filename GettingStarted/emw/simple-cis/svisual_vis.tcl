#setdep @node|emw@
load_library physicalconstants
set c [expr $::const::SpeedOfLight*1e6] ;# um/s

##############################################################################
# B A T C H 
if {![info exists runVisualizerNodesTogether]} {
  set n @node|emw@
  # skip if emw was running in test mode only, hence R was ot extracted. 
  #if @<![string is double R ] || ![string is double T ]>@
  puts "R or T does not exist so no valid emw results detected."
  puts "Rerun emw or click on menu Extensions>Reconstruct Extracted Results"
  exit 1
  #endif
  
  # for snmesh and emw log extraction
  source @pwd@/lib/mylog.tcl
  
  #-----
  puts "define some dataset and variable names" 
  set outfile   "n${n}_eml.out"
  set logfile   "n${n}_eml.log"
  set ds($n)    [file tail [file rootname @plot@]]
  set dsRTA($n) "$ds($n)_sensor(RTA,transient)"
  set varTF     "TFIntegr PlaneZmin/PhotonFluxDensity"   
  set varF      "%sensor%Integr PlaneZmin/PhotonFluxDensity"
  set sensName  "F%sensor%"
  !(
  if {![info exists sensorZFlux]} {set sensorZFlux {}}
  puts "set sensorZFlux {$sensorZFlux}"
  if {![info exists sensorMaterials]} {set sensorMaterials {}}
  puts "set sensorMaterials {$sensorMaterials}"
  )!
  set varR    "RIntegr PlaneZmax/PhotonFluxDensity"    
  set varT    "TIntegr PlaneZmin/PhotonFluxDensity"    
  set varA    "AIntegr Box/AbsorbedPhotonDensity"
  set R 0
  #if @<[string is double R ]>@
  set R @R@
  #endif
  set T 0
  #if @<[string is double T ]>@
  set T @T@
  #endif
  #if @<[string is double A ]>@
  set A @A@                          
  #else
  puts "Warning: no A found, assuming A=1-R-T."
  set A [expr 1. - $R - $T]
  #endif
  #-----
  puts "load emw plot file"
  load_file_datasets "@plot@" ;# returns the all geometries or "dataset name"
  
  #-----
  puts "calculate incident photon fluxes needed as reference for flux sensors"
  set NTF [lindex [get_variable_data $varTF   -dataset $ds($n)] end]
  set Nr  [lindex [get_variable_data $varR    -dataset $ds($n)] end] 
  set Ni  [expr $NTF+$Nr]

  #-----
  #if [string match "*finalAonly*" "@model@"]
  puts "if A sensor was setup separately and not in RTA section compute and output it here"
  if {[list_variables -dataset $ds($n) $varA] != ""} {
    set Na [lindex [get_variable_data $varA   -dataset $ds($n)] end]
    set A  [expr 1.*$Na/$Ni]
    puts [format "DOE: A %.4g"  $A]
  }
  #endif
  
  #-----
  puts "calculate relative flux for flux sensors"
  # sensor names as they appear in plt
  set fluxSensors {}
  foreach {l z} [lsort -stride 2 -index 1 $sensorZFlux] { ;# sorted according to z coordinate
    lappend fluxSensors [string map "%sensor% $l" $sensName]
  }
  set fluxSensors [concat {TF} $fluxSensors] ;# add TF sensor from RTA section at top   
  # get all flux sensor values and compute relative flux
  foreach l $fluxSensors {
    set vs [string map "%sensor% $l" $varF]
    if {[list_variables -dataset $ds($n) $vs] != ""} {
      set NF [lindex [get_variable_data $vs   -dataset $ds($n)] end]
    } else {
      set NF 0
    }
    set F($l) [expr 1.*$NF/$Ni]
  }
  
  #-----
  puts "calculate absorption for all absorption sensors"
  set Asum 0
  foreach v [list_variables -dataset $ds($n) "A*Integr"] {
    # get sensor name A(*)Integr AbsorbedPhotonDensity
    set s [regsub {A(\S+)Integr.*} $v {\1}]   
    # skip when match fails e.g. AIntegr
    if {"$s" == "$v"} {continue}
    # calculate A
    set N [lindex [get_variable_data $v -dataset $ds($n)] end]
    set Ar($s) [expr 1.*$N/$Ni]
    #  puts "Ar($s)=$Ar($s)"
    # sum up only certain sensors 
    if {[lsearch $sensorMaterials $s] > -1} {
      #  puts "add to Asum: $s"
      set Asum [expr $Asum+$Ar($s)]
    }
  }
  #  puts "Asum=$Asum"
  
  #-----       
  puts "extract runtime statistics from log"
  array set res  [mylog::getRuntimeFromEmwLog $outfile]
  array set prof [mylog::getProfileFromEmwLog $logfile]
  
  #-----
  puts "extract propagation distance"
  set ct    [expr $res(dt)*$res(timeSteps)*$c];#um
  # step rate, how many steps are required to propagate 1 um
  set Rstep [expr ($ct != 0 ? $res(timeSteps)/$ct : 0)] ;# steps/um
  
  #-----
  puts "output to swb"                                                         
  puts [format "DOE: RTA %.4g"  [expr $R+$T+$A]]
  #-
  puts [format "DOE: __ABS___ _____"]
  foreach s [lsort -dictionary [array names Ar]] {
    puts [format "DOE: A$s %.4f" $Ar($s)]
  }
  puts [format "DOE: Asum %.4f" $Asum]
  #-
  puts [format "DOE: __FLUX__ _____"]
  foreach s $fluxSensors {
    puts [format "DOE: ${s} %.4f" $F($s)]
  }
  #-
  puts [format "DOE: __PROP__ _____"]
  puts [format "DOE: ct %.4g" $ct]
  puts [format "DOE: Rstep %.4g" $Rstep]
  #-
  puts [format "DOE: __STAT__ _____"]
  puts [format "DOE: Mcells %.4g" [expr 1e-6*$res(cells)]]
  puts [format "DOE: Nsteps %.4g" $res(timeSteps)]
  puts [format "DOE: Ttot %.4g" $res(totalTime)]
  puts [format "DOE: Vthru %.4g" [expr 1e-6*$res(cells)*$res(timeSteps)/$res(fdtdTime)]]
}

##############################################################################
# I N T E R A C T I V E 
if {[info exists runVisualizerNodesTogether]} {
  #- File settings
  set n              "@node@"
  set nemw           "@node|emw@"
  set MYDATAFILE($n) "@plot@"
  set STATUSFILE($n) "[file rootname $MYDATAFILE($n)].sta"
  
  #-Plot settings
  set TITLE       ""                          ;# Plot title
  set XLABEL         {ct [<greek>m</greek>m]} ;# Label for x-axis
  set YLABEL         "Max. Dev., 1-RTA"       ;# Label for y-axis
  set Y2LABEL        "R,T,A"                  ;# Label for y2-axis
  if {0 < @tol@ && @tol@ < 1} {
    set YRANGE    {@<0.5*tol>@ 1.0} ;# if tolerance used for detector set range for y-axis values
  } else {
    set YRANGE    {1e-6 1.0}        ;# Set range for y-axis values
  }
  set Y2RANGE     {0 1.1}           ;# Set range for y2-axis values
  set LEGENDPOS   "top_right"       ;# Position of legend on plot
  #-Auto-Update settings
  set UPDATE       0                ;# updates the plot until emw is finished
  set WAIT         10               ;# Time between updates [seconds]

  #- dataset names
  set ds($n)         "n${nemw}_eml"
  set dsDetector($n) "$ds($n)_detector"
  set dsRTA($n)      "$ds($n)_sensor(RTA,transient)"
  set dsR($n)        "$ds($n)_sensor(R,transient)"
  set dsT($n)        "$ds($n)_sensor(T,transient)"
  set dsTF($n)       "$ds($n)_sensor(TF,transient)"
  set dsMe($n)       "$ds($n)_sensor(TFMe,transient)"
  set dsA($n)        "$ds($n)_sensor(A,transient)"
  
  #- variables
  set varTime   "Time"
  set varMaxDev "MaxDeviation"
  set varTol    "Tolerance"
  set varRsens  "Integr PlaneZmax/PhotonFluxDensity"
  set varTFsens "Integr PlaneZmin/PhotonFluxDensity"
  set varTsens  "Integr PlaneZmin/PhotonFluxDensity"
  set varAsens  "Integr Box/AbsorbedPhotonDensity"
  set varR      "R"
  set varT      "T"
  set varA      "A"
  set varRTA    "RTA"
  
  #- create plots - use $:: to access above defined variables
  proc create_plots {} {
    set ::MYPLOT [create_plot -1d]
    set_plot_prop -show_grid -title $::TITLE -title_font_size 18 -show_legend
    set_axis_prop -title_font_size 16 -label_font_size 14
    set_axis_prop -axis x -title $::XLABEL 
    set_axis_prop -axis y -type log -title $::YLABEL 
    set_axis_prop -axis y2 -title $::Y2LABEL 
    set_legend_prop -location $::LEGENDPOS -label_font_size 14
  }
  
  #- create curves - use $:: to access above defined variables
  proc create_curves {} {
    echo "create curves"
    if {[list_datasets $::dsDetector($::n)] != ""} {
      echo "create monitor curve"             
      create_curve -name cMaxDev($::n) -dataset $::dsDetector($::n) -axisX $::varTime -axisY $::varMaxDev
      set_curve_prop cMaxDev($::n) -color $::color -line_width 2 -label "Max Dev.: $::legend"
      create_curve -name cTol($::n) -dataset $::dsDetector($::n) -axisX $::varTime -axisY $::varTol
      set_curve_prop cTol($::n) -line_width 2 -line_style dash -color $::color -hide_markers -label "Tolerance: $::legend"
    }
    if {[list_datasets $::dsRTA($::n)] != ""} {
      echo "create R,T,A,RTA curves"
      if {[list_variables -dataset $::dsRTA($::n) $::varR] != ""} {
        echo "create R"
        create_curve -name cR($::n) -dataset $::dsRTA($::n) -axisX $::varTime -axisY $::varR
        set_curve_prop cR($::n) -label "R: $::legend" -color $::color -show_markers -markers_type circle  -markers_size 8 -axis right
        # set_curve_prop cR($::n) -hide
      }
      if {[list_variables -dataset $::dsRTA($::n) $::varT] != ""} {
        echo "create T"
        create_curve -name cT($::n) -dataset $::dsRTA($::n) -axisX $::varTime -axisY $::varT
        set_curve_prop cT($::n) -label "T: $::legend" -color $::color -show_markers -markers_type square  -markers_size 8 -axis right
        # set_curve_prop cT($::n) -hide
      }
      if {[list_datasets $::dsA($::n)] != "" && [list_variables -dataset $::dsA($::n) $::varAsens] != ""} {
        echo "create A (from RTA)"
        create_curve -name cNr  -dataset $::dsR($::n)  -axisX $::varTime -axisY $::varRsens
        create_curve -name cNtf -dataset $::dsTF($::n) -axisX $::varTime -axisY $::varTFsens
        create_curve -name cNa  -dataset $::dsA($::n)  -axisX $::varTime -axisY $::varAsens
        create_curve -name cA($::n) -function "<cNa>/(<cNr>+<cNtf>)"
        set_curve_prop cA($::n) -label "Ah: $::legend" -color $::color -show_markers -markers_type diamond -markers_size 8 -axis right
        # set_curve_prop cA($::n) -hide
        remove_curves {cNr cNtf cNa}
      } elseif {[list_datasets $::dsA($::n)] != "" && [list_variables -dataset $::dsA($::n) $::varA] != ""} {
        echo "create A (from A)"
        create_curve -name cA($::n) -dataset $::dsA($::n) -axisX $::varTime -axisY $::varA
        set_curve_prop cA($::n) -label "A: $::legend" -color $::color -show_markers -markers_type diamond -markers_size 8 -axis right
        # set_curve_prop cA($::n) -hide
      }
      if {[list_variables -dataset $::dsRTA($::n) $::varRTA] != ""} {
        echo "create RTA"
        create_curve -name cRTA($::n) -dataset $::dsRTA($::n) -axisX $::varTime -axisY $::varRTA
        set_curve_prop cRTA($::n) -hide
        create_curve -name c1_RTA($::n) -function "1-<cRTA($::n)>"
        set_curve_prop c1_RTA($::n) -label "1-RTA: $::legend" -color $::color -show_markers -markers_type cross -line_width 4
      } elseif {[list_curves "cR($::n)"] != "" && [list_curves "cT($::n)"] != "" && [list_curves "cA($::n)"] != ""} {
        echo "create 1-R-T-A"
        create_curve -name c1_RTA($::n) -function "1-<cR($::n)>-<cT($::n)>-<cA($::n)>"
        set_curve_prop c1_RTA($::n) -label "1-RTA: $::legend" -color $::color -show_markers -markers_type cross -line_width 4
        # set_curve_prop c1_RTA($::n) -hide
      }
    }
    # scale x axis of all curves to cT
    if {[string match -nocase "*ct*" "$::XLABEL"]} {
      foreach cv [concat [list_curves "*($::n)*"] [list_curves "*($::n,*)*"]] {
        if {![string match "c1_RTA*" "$cv"]} {
          echo "scale $cv with $::c"
          set_curve_prop $cv -xScale $::c
        }
      }
    }
  } ;# end create_curves
  
  ##############################################################################
  # NO CHANGES BELOW THIS LINE
  
  proc jobStatus {staFile} {
    set status ""
    if {![file exists $staFile]} {
      return $status 
    }
    set fid [open $staFile r]
    set line [string trim [gets $fid]]
    close $fid
    if {[string length $line] > 0} {
      set line [split $line "|"]
      if {[llength $line] >= 3} {
        set status [lindex $line 2]
      }
    }
    return $status
  }
  
  # wait for pending nodes until a plt exists and we can load it
  set wait 0
  for {set i 0} {$i < 100} {incr i} {
    set emwStatus [jobStatus $STATUSFILE($n)]
    if {[string match "*$emwStatus*" "queued,ready,pending,running"]} {set wait 1} 
    set loaded [expr [catch "load_file $MYDATAFILE($n)"] == 0]
    #-Load .plt datafile
    if {!$loaded} {
      echo "Failed loading $MYDATAFILE($n)"
      if {[string match "*$emwStatus*" "queued,ready,pending,running"]} {
        echo "EMW node is $emwStatus. Trying again ..."
        after [expr {int(500+rand() * 1000)}]
      } else { 
        break 
      }
    } else { 
      break
    }
  }
  # echo "loaded: $loaded emwStatus: $emwStatus wait: $wait ds: [list_datasets]"
  # if loading succeeded create curves
  if {$loaded} {
    if {[llength [list_plots]] == 0} {
      echo "create plots"
      create_plots
    }
    if {[llength [list_datasets "*,transient)"]] > 0} { 
      echo "create curves"
      create_curves
    }
    if {$cv_index == 1} { 
      echo "for first node"
      if {[llength $YRANGE] == 2} {
        set_axis_prop -axis y -range $YRANGE -min_fixed -max_fixed
      }
      if {[llength $Y2RANGE] == 2} {
        set_axis_prop -axis y2 -range $Y2RANGE -min_fixed -max_fixed
      }
      
    }
    
    #-------------------------------------------------------------------------------
    echo "refresh plot, after the script of the last selected node ran"
    echo "nodelist: $nodelist n: $n"
    if {$UPDATE && [lindex $nodelist end] == $n} {
      echo "refresh"
      for {set i 0} {$i < 9999} {incr i} {
        # set updateDatasets {}
        set states {}
        foreach sn $nodelist {
          lappend states [jobStatus $ds($sn).sta]
          # lappend updateDatasets $dsDetector($sn)
        }             
        echo "collapse all states to a single status"
        set states [lsort -unique $states]
        set swait 0
        foreach s {"queued" "ready" "pending" "running"} {
          if {[lsearch $states $s] > -1} { set swait 1 ; break }
        }
        echo "states: $states swait: $swait"
        if {$swait} {
          set_plot_prop -title "$TITLE (status=[join $states "/"])"
          after [expr {int(($WAIT+rand())*1000)}]
          # catch "reload_datasets \"$updateDatasets\""
          catch "reload_datasets {}"
          remove_curves [list_curves]
          create_curves
          #catch "reload_datasets \"[list_datasets]\""
          #catch "reload_files [list_files]"
          #catch "eval {reload_datasets [list_datasets]}"
        } else {
          set_plot_prop -title "$TITLE"
          break
        }
      }
    }
  }
  if {$UPDATE && [lindex $nodelist end] == $n && !$loaded && $wait} {
    show_msg -warning -title "auto-refresh" \
      "Auto refresh could not be started, because failed to load last node data."
  } 
}