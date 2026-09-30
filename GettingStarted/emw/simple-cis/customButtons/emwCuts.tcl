#------------------------------------------------------------------------------- 
# Sentaurus Visual Custom Button
namespace eval ::emwCuts {
  variable label {emw cuts}
  variable description {fixes orientation of coord. sys. for emw cuts}
  variable icon {emwCuts.gif} ;# path to gif,png or bmp ideally 24x24.
  # USER CONFIG
  variable link 1 ;# whether to link cutsplots with same cut direction toegether
  variable showFields 1 ;# whether fields should be shown
  variable showContour 1 ;# whether to show n&k as contour
  # END USER CONFIG
  variable correctedPlots {} ;# list of plots the button ran on already
  
  #-------------------------------------------------------------------------------
  proc run {} {
    variable correctedPlots
    variable link
    variable showFields
    variable showContour
    # save currently selected plots
    set selected [list_plots -selected]
    # unlink all 2d plots
    link_plots [list_plots -dim 2] -unlink                                       
    # loop through all 2D plots
    array set plots {}
    foreach p [list_plots -dim 2] {
      select_plots [list $p]
      if {[lsearch $correctedPlots $p] > -1} {
        echo "axes already corrected for plot $p."
        continue
      }
      # get tdr CS orientation UCS or DFISE
      if {[get_plot_prop -axes_interchanged]} {
        set cs ucs
      } else {
        set cs dfise
      }
      # fix axis orientation of cuts 
      if {"$cs" == "dfise"} {
      switch -regexp $p {
        (E|Eabs|G|APD)x {
            echo "DFISE x-cut: $p"
          set_plot_prop -not_axes_interchanged
          set_axis_prop -axis x -title Y -not_inverted 
          set_axis_prop -axis y -title Z -not_inverted
          lappend plots(x) $p
        }                      
        (E|Eabs|G|APD)y {                   
            echo "DFISE y-cut: $p"
          set_plot_prop -axes_interchanged
          set_axis_prop -axis x -title Z -not_inverted
          set_axis_prop -axis y -title X -not_inverted
          lappend plots(y) $p
        }
        (E|Eabs|G|APD)z {
            echo "DFISE z-cut: $p"
          set_plot_prop -not_axes_interchanged
          set_axis_prop -axis x -title X -not_inverted
          set_axis_prop -axis y -title Y -not_inverted
          lappend plots(z) $p
        }
      }
      } else {
        switch -regexp $p {
          (E|Eabs|G|APD)x {
            echo "UCS x-cut viewed from top: $p"
            set_plot_prop -not_axes_interchanged
            set_axis_prop -axis x -title Y -not_inverted 
            set_axis_prop -axis y -title Z -not_inverted
            lappend plots(x) $p
          }                      
          (E|Eabs|G|APD)y {                   
            echo "UCS y-cut viewed from right: $p"
            set_plot_prop -not_axes_interchanged
            set_axis_prop -axis x -title Z -not_inverted
            set_axis_prop -axis y -title X -inverted
            lappend plots(y) $p
          }
          (E|Eabs|G|APD)z {
            echo "UCS z-cut viewed from front: $p"
            set_plot_prop -axes_interchanged
            set_axis_prop -axis x -title X -inverted
            set_axis_prop -axis y -title Y -not_inverted
            lappend plots(z) $p
          }
        }
      }
      # select a reasonable field if available
      if {$showFields} {
      foreach f {"Abs(AbsElectricField-V)" "AbsorbedPhotonDensity" "OpticalGeneration" "Abs(PowerFluxDensity-V)"} {
        if {[llength [list_fields $f]] > 0} {
          set_field_prop $f -show_bands
          break
        }
      }
      }
      # if no regions were saved, try to activate n or k as contour
      if {$showContour} {
      if {[list_regions] == "Anymaterial"} {   
        foreach f {"cplxRefIndex" "cplxExtCoeff" } {
          if {[llength [list_fields $f]] > 0} {
            set_field_prop cplxRefIndex -show
          }
        }
      }
    }
      # remember to which plot we applied this correction already 
      lappend correctedPlots $p
    }
    # link movement of cuts in same direction together
    if {$link} {
    foreach dir [array names plots] {
      if {[llength $plots($dir)] > 1} {
      	echo "linking $plots($dir)"
        link_plots $plots($dir) -special {axes_prop move matreg blanking}
        }
      }
    }
    # restore selected plot
    select_plots $selected
  }
}
# :mode=svisual:
