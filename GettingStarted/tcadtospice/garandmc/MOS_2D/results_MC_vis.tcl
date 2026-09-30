#if "@Type@" == "nMOS"
set nfile INTERMITTENT_ELEC_OUTPUT
set AreaFactor 1
set semiconductors {Silicon}
#elif "@Type@" == "pMOS"
set nfile INTERMITTENT_HOLE_OUTPUT
set AreaFactor -1
set semiconductors {Silicon SiliconGermanium}
#endif

set FILE @pwd@/@nodedir|Garand_MC@/n@node|Garand_MC@_gmc.out
echo $FILE

set tH 0
set tM 0
set tS 0

if { [file exists $FILE] == 1} {
    echo "Open file: $FILE"
    set f [open $FILE]
    set lines [split [read $f] \n]
    close $f

    foreach line $lines {
        if { [regexp {TOTAL SIMULATION TIME \(inc. INITIALIZATION\)} $line] } {
            echo $line 
            regsub -all {\s+ :} $line { } tlist
            puts $tlist
            set tH 0; set tM 0; set tS 0;
            set ti 0
            foreach ts $tlist {
                if { $ts == "hours" || $ts == "hour" } {
                    set pti [expr ($ti-1)]
                    set tH [lindex $tlist $pti]
                } elseif { $ts == "minutes" || $ts == "minute" } {
                    set pti [expr ($ti-1)]
                    set tM [lindex $tlist $pti]
                } elseif { $ts == "seconds" || $ts == "second" } {
                    set pti [expr ($ti-1)]
                    set tS [lindex $tlist $pti]
                }
            set ti [expr ($ti+1)]
            }
        }
    }
puts "DOE: Total_Simulation_Time ${tH}h_${tM}m_${tS}s"

}

#################################

## Define field names based upon device type
#if "@Type@" == "nMOS"
  set prefix e
#elseif "@Type@" == "pMOS"
  set prefix h
#else
  puts "Unknown device type. Expected 'nMOS' or 'pMOS'"
#endif

## Physical device parameters and useful conversion factors (for clarity)
set width 0.001
set Vg @Vg@
set Vd @Vd@
set DDNODE @node|Garand_DD@
set MCNODE @node|Garand_MC@
set chan_dir  y
set start_pos -0.061
set end_pos    0.061




## If DD simulation TDR file exists, etract data
set FILE @pwd@/results/nodes/${DDNODE}/n${DDNODE}-DD-Output_1.tdr
puts "TEST EXISTENCE OF DD FILE: $FILE"

if { [file exists $FILE] == 1} {
    puts "DD FILE EXISTS"

    set dataset [load_file $FILE]

    set plot [create_plot -dataset $dataset]
    select_plots $plot

##  Check available fields so we know what we are dealing with

    set avail_fields [list_fields]
    echo $avail_fields

    set foundRho false
    set foundPot false
    set foundBE  false
    set foundQEf false
    set foundJ   false

    foreach F $avail_fields {
        if { "$F" == "${prefix}Density"              } { set foundRho true }
        if { "$F" == "ElectrostaticPotential"        } { set foundPot true }
        if { "$F" == "ConductionBandEnergy"          } { set foundBE  true }
        if { "$F" == "${prefix}QuasiFermiEnergy"     } { set foundQEf true }
        if { "$F" == "${prefix}CurrentDensity-X"     } { set foundJ   true }
    }

    if { $foundRho } {
        echo "DD Carrier density found" 
        } {
        echo "No DD carrier density found, unweighted profiles will be written."
        }
    if { $foundPot } { echo "Potential found" }
    if { $foundBE  } { echo "Band edges found" }
    if { $foundJ   } { echo "Current density found" }

##  Define lists to hold channel position and weighted field data for this bias

    set pos  [list]
    set dens [list]
    set pot  [list]
    set cbe  [list]
    set qef  [list]
    set vbe  [list]
    set jx   [list]
    set jy   [list]
    set jz   [list]

##  Create carrier weighted fields to integrate over

    if { $foundRho } { create_field -plot $plot -name DDDens  -function <${prefix}Density> }
    if { $foundPot } { create_field -plot $plot -name Pot     -function <DDDens>*<ElectrostaticPotential> }
    if { $foundBE  } { 
        create_field -plot $plot -name Cbe -function <DDDens>*<ConductionBandEnergy> 
        create_field -plot $plot -name Vbe -function <DDDens>*<ValenceBandEnergy> 
        create_field -plot $plot -name B   -function exp(-0.025852*<ConductionBandEnergy>)
    }
    if { $foundQEf } { create_field -plot $plot -name QEf -function <DDDens>*<${prefix}QuasiFermiEnergy> }
    if { $foundJ   } {
        create_field -plot $plot -name J-X -function <DDDens>*<${prefix}CurrentDensity-X>
        create_field -plot $plot -name J-Y -function <DDDens>*<${prefix}CurrentDensity-Y>
        create_field -plot $plot -name J-Z -function <DDDens>*<${prefix}CurrentDensity-Z>
    }

##  Create multiple cutplanes normal to the channel direction

    for {set i 0} {$i <= @num_slices@} {incr i} {

##      Determine cutline position along channel (append to list) and create the cutline

        set chan_pos [expr $start_pos + $i*($end_pos-$start_pos)/@num_slices@]
        lappend pos  $chan_pos

        set cutplane [create_cutplane -plot $plot -type $chan_dir -at $chan_pos]

        set cut_plot($i) [create_plot -dataset $cutplane -ref_plot $plot]
        select_plots $cut_plot($i)

##      Integrate carrier density for normalisation
        set integrated_area  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field DDDens -returndomain]
        set integrated_dens  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field DDDens]
        lappend dens         [expr $integrated_dens/$integrated_area]

##      Append carrier weighted field data to lists
##      Svisual converts density from [/cm3] to [/um3] so that when integrating over the 
##      volume, which is assumed to be [um3], the result is dimensionless.
##      Svisual only does this for the density, not for other fields with other dimensions.
##      As we are using the density as a weight for the numerator, we must make sure it's also scaled in the same manner.

##      Integrate carrier-weighted fields (potential and band edges first)

        if { $foundPot } {
          set integrated_pot [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Pot  ]
          lappend pot        [expr $integrated_pot / $integrated_dens]
        }

        if { $foundBE  } {
          set integrated_cbe [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Cbe  ]
          set integrated_vbe [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Vbe  ]
          set integrated_B   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field B    ]
          lappend cbe        [expr $integrated_cbe / $integrated_dens]
          lappend vbe        [expr $integrated_vbe / $integrated_dens]
          lappend B          [expr $integrated_B   / $integrated_area]
        }

        if { $foundQEf } {
          set integrated_qef [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field QEf  ]
          lappend qef        [expr $integrated_qef / $integrated_dens]
        }

        if { $foundJ } {
          set integrated_jx  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}CurrentDensity-X]
          set integrated_jy  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}CurrentDensity-Y]
          set integrated_jz  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}CurrentDensity-Z]
          lappend jx         $integrated_jx
          lappend jy         $integrated_jy
          lappend jz         $integrated_jz
        }
##      Cleanup cutplane plots
        remove_plots $cut_plot($i)
    }
##  Create output data file names - one for each thing we extract

    if { $foundRho } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}DDDensity.csv w]
      puts $outfile "Position, ${prefix}DDDensity"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $dens $i]" }
      close $outfile
    }

    if { $foundPot } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_DD_potential.csv w]
      puts $outfile "Position, ${prefix}ElectrostaticPotential"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $pot $i]" }
      close $outfile
    }

    if { $foundBE } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_DDConductionBandEnergy.csv w]
      puts $outfile "Position, ConductionBandEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $cbe $i]" }
      close $outfile

      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_DDValenceBandEnergy.csv w]
      puts $outfile "Position, ValenceBandEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vbe $i]" }
      close $outfile

      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_DDAverageConductionBandEnergy.csv w]
      puts $outfile "Position, AverageConductionBandEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $B $i]" }
      close $outfile
    }

    if { $foundQEf } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_DDQuasiFermiEnergy.csv w]
      puts $outfile "Position, ${prefix}QuasiFermiEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $qef $i]" }
      close $outfile
    }

    if { $foundJ } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}DDCurrent-X.csv w]
      puts $outfile "Position, ${prefix}DDCurrent-X"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jx $i]" }
      close $outfile

      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}DDCurrent-Y.csv w]
      puts $outfile "Position, ${prefix}DDCurrent-Y"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jy $i]" }
      close $outfile

      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}DDCurrent-Z.csv w]
      puts $outfile "Position, ${prefix}DDCurrent-Z"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jz $i]" }
      close $outfile
    }
} {
    puts "DD FILE DOES NOT EXIST"
}





## If MC simulation TDR file exists, etract data
set FILE @pwd@/results/nodes/${MCNODE}/n${MCNODE}-MC-Output.tdr
puts "TEST EXISTENCE OF MC FILE: $FILE"

if { [file exists $FILE] == 1} {
    puts "MC FILE EXISTS"

    set dataset [load_file $FILE]

    set plot [create_plot -dataset $dataset]
    select_plots $plot

##  Check available fields so we know what we are dealing with

    set avail_fields [list_fields]
    echo $avail_fields

    set foundRho false
    set foundPot false
    set foundBE  false
    set foundQEf false
    set foundVel false
    set foundEk  false
    set foundJ   false
    set foundBal false

    foreach F $avail_fields {
        if { "$F" == "ElectrostaticPotential"        } { set foundPot true }
        if { "$F" == "ConductionBandEnergy"          } { set foundBE true }
        if { "$F" == "${prefix}QuasiFermiEnergy"     } { set foundQEf true }
        if { "$F" == "${prefix}MCDensity"            } { set foundRho true }
        if { "$F" == "${prefix}MCDensityForward"     } { set foundRho true; set foundBal true }
        if { "$F" == "${prefix}MCVelocity-X"         } { set foundVel true }
        if { "$F" == "${prefix}MCVelocityForward-X"  } { set foundVel true; set foundBal true }
        if { "$F" == "${prefix}MCCurrent-X"          } { set foundJ true   } 
        if { "$F" == "${prefix}MCCurrentForward-X"   } { set foundJ true; set foundBal true   } 
        if { "$F" == "${prefix}MCEk"                 } { set foundEk  true }
        if { "$F" == "${prefix}MCEkForward"          } { set foundEk  true; set foundBal true }
    }

    if { $foundRho } {
        echo "Carrier density found" 
        } {
        echo "No carrier density found, unweighted profiles will be written."
        }
    if { $foundPot } { echo "Potential found" }
    if { $foundBE  } { echo "Band edges found" }
    if { $foundVel } { echo "Velocity found" }
    if { $foundEk  } { echo "Kinetic energy found" }
    if { $foundJ   } { echo "Current density found" }
    if { $foundBal } { 
        if { $foundBE == false } {
            echo "No fields for band edges found, ballistic output not being produced."
            set foundBal false
        } {
            echo "Ballistic output found" 
        }
    }




##  Define lists to hold channel position and weighted field data for this bias

    set pos  [list]
    set pot  [list]
    set cbe  [list]
    set qef  [list]
    set vbe  [list]
    set dens [list]

    if { $foundBal } {
        set densf [list]
        set densb [list]
        set vfx   [list]
        set vbx   [list]
        set vfy   [list]
        set vby   [list]
        set vfz   [list]
        set vbz   [list]
        set jfx   [list]
        set jbx   [list]
        set jfy   [list]
        set jby   [list]
        set jfz   [list]
        set jbz   [list]
        set ekf   [list]
        set ekb   [list]
    } {
        set vx   [list]
        set vy   [list]
        set vz   [list]
        set jx   [list]
        set jy   [list]
        set jz   [list]
        set ek   [list]
    }

##  Create carrier weighted fields to integrate over

    if { $foundRho } {
        create_field -plot $plot -name MCDens   -function <${prefix}MCDensity>
        if { $foundBal } {
            create_field -plot $plot -name MCDensf  -function <${prefix}MCDensityForward>
            create_field -plot $plot -name MCDensb  -function <${prefix}MCDensityBackward>
        }
    } {
#if "@Type@" == "nMOS"
        echo "No carrier density found, please re-run with OUTPUT electrons = on"
#elseif "@Type@" == "pMOS"
        echo "No carrier density found, please re-run with OUTPUT holes = on"
#endif
        exit
    }

##  Set up potential

    if { $foundPot } { create_field -plot $plot -name Pot   -function <MCDens>*<ElectrostaticPotential> }

##  Set up band edges

    if { $foundBE  } { 
        create_field -plot $plot -name Cbe   -function <MCDens>*<ConductionBandEnergy> 
        create_field -plot $plot -name Vbe   -function <MCDens>*<ValenceBandEnergy> 
    }

    if { $foundQEf } { create_field -plot $plot -name QEf   -function <MCDens>*<${prefix}QuasiFermiEnergy> }

##  Set up remaining parameters, accounting for ballisticity

    if { $foundBal } {
        if { $foundVel } {
            create_field -plot $plot -name Velf-X -function <MCDensf>*<${prefix}MCVelocityForward-X>
            create_field -plot $plot -name Velf-Y -function <MCDensf>*<${prefix}MCVelocityForward-Y>
            create_field -plot $plot -name Velf-Z -function <MCDensf>*<${prefix}MCVelocityForward-Z>
            create_field -plot $plot -name Velb-X -function <MCDensb>*<${prefix}MCVelocityBackward-X>
            create_field -plot $plot -name Velb-Y -function <MCDensb>*<${prefix}MCVelocityBackward-Y>
            create_field -plot $plot -name Velb-Z -function <MCDensb>*<${prefix}MCVelocityBackward-Z>
        }
        if { $foundEk  } {
            create_field -plot $plot -name Ekf    -function <MCDensf>*<${prefix}MCEkForward>
            create_field -plot $plot -name Ekb    -function <MCDensb>*<${prefix}MCEkBackward>
        }
    } {
        if { $foundVel } {
            create_field -plot $plot -name Vel-X -function <MCDens>*<${prefix}MCVelocity-X>
            create_field -plot $plot -name Vel-Y -function <MCDens>*<${prefix}MCVelocity-Y>
            create_field -plot $plot -name Vel-Z -function <MCDens>*<${prefix}MCVelocity-Z>
        }
        if { $foundEk  } { create_field -plot $plot -name Ek    -function <MCDens>*<${prefix}MCEk> }
    }

##  Create multiple cutplanes normal to the channel direction

    for {set i 0} {$i <= @num_slices@} {incr i} {

##    Determine cutline position along channel (append to list) and create the cutline

        set chan_pos [expr $start_pos + $i*($end_pos-$start_pos)/@num_slices@]
        lappend pos  $chan_pos

        echo "Create cutplane in MC domain at $chan_dir = $chan_pos \[um\]"
        set cutplane [create_cutplane -plot $plot -type $chan_dir -at $chan_pos]

        set cut_plot($i) [create_plot -dataset $cutplane -ref_plot $plot]
        select_plots $cut_plot($i)

##      Integrate carrier density for normalisation

        set integrated_area  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field MCDens -returndomain]
        set integrated_dens  [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field MCDens]
        lappend dens         [expr $integrated_dens / $integrated_area]

        if { $foundBal } {
          set integrated_densf [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field MCDensf]
          set integrated_densb [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field MCDensb]
          lappend densf        [expr $integrated_densf /$width]
          lappend densb        [expr $integrated_densb /$width]
        } 

##      Append carrier weighted field data to lists
##      Svisual converts density from [/cm3] to [/um3] so that when integrating over the 
##      volume, which is assumed to be [um3], the result is dimensionless.
##      Svisual only does this for the density, not for other fields with other dimensions.
##      As we are using the density as a weight for the numerator, we must make sure it's also scaled in the same manner.
##      Integrate carrier-weighted fields (potential and band edges first)

      if { $foundPot } {
        set integrated_pot [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Pot  ]
        if { $integrated_dens > 0 } {
          lappend pot      [expr $integrated_pot / $integrated_dens]
        } else {
          lappend pot      $integrated_pot
        }
      }

      if { $foundBE  } {
        set integrated_cbe [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Cbe  ]
        set integrated_vbe [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Vbe  ]
        if { $integrated_dens > 0 } {
          lappend cbe      [expr $integrated_cbe / $integrated_dens]
          lappend vbe      [expr $integrated_vbe / $integrated_dens]
        } else {
          lappend cbe      $integrated_cbe
          lappend vbe      $integrated_vbe
        }
      }

      if { $foundQEf } {
        set integrated_qef [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field QEf  ]
        if { $integrated_dens > 0 } {
          lappend qef      [expr $integrated_qef / $integrated_dens]
        } else {
          lappend qef      $integrated_qef
        }
      }
 
##    Split on ballistic output

      if { $foundBal } {
##        Integrate carrier-weighted fields and append carrier weighted field data to lists

        if { $foundVel } {
          set integrated_vfx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velf-X]
          set integrated_vbx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velb-X]
          set integrated_vfy   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velf-Y]
          set integrated_vby   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velb-Y]
          set integrated_vfz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velf-Z]
          set integrated_vbz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Velb-Z]
          lappend vfx          [expr $integrated_vfx / $integrated_densf] 
          lappend vbx          [expr $integrated_vbx / $integrated_densb] 
          lappend vfy          [expr $integrated_vfy / $integrated_densf] 
          lappend vby          [expr $integrated_vby / $integrated_densb] 
          lappend vfz          [expr $integrated_vfz / $integrated_densf] 
          lappend vbz          [expr $integrated_vbz / $integrated_densb] 
        }
        if { $foundJ } {
          set integrated_jfx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentForward-X]
          set integrated_jbx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentBackward-X]
          set integrated_jfy   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentForward-Y]
          set integrated_jby   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentBackward-Y]
          set integrated_jfz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentForward-Z]
          set integrated_jbz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrentBackward-Z]
          lappend jfx          $integrated_jfx
          lappend jbx          $integrated_jbx
          lappend jfy          $integrated_jfy
          lappend jby          $integrated_jby
          lappend jfz          $integrated_jfz
          lappend jbz          $integrated_jbz
        }
        if { $foundEk } {
          set integrated_ekf   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Ekf   ]
          set integrated_ekb   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Ekb   ]
          lappend ekf          [expr $integrated_ekf / $integrated_densf] 
          lappend ekb          [expr $integrated_ekb / $integrated_densb] 
        }
      } else {
##        Integrate carrier-weighted fields and append carrier weighted field data to lists

        if { $foundVel } {
          set integrated_vx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Vel-X]
          set integrated_vy   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Vel-Y]
          set integrated_vz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Vel-Z]
          if { $integrated_dens > 0 } {
            lappend vx   [expr $integrated_vx / $integrated_dens]
            lappend vy   [expr $integrated_vy / $integrated_dens]
            lappend vz   [expr $integrated_vz / $integrated_dens]
          } else {
            lappend vx   $integrated_vx
            lappend vy   $integrated_vy
            lappend vz   $integrated_vz
          }
        }
        if { $foundJ } {
          set integrated_jx   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrent-X]
          set integrated_jy   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrent-Y]
          set integrated_jz   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field ${prefix}MCCurrent-Z]
          lappend jx          $integrated_jx
          lappend jy          $integrated_jy
          lappend jz          $integrated_jz
        }
        if { $foundEk } {
          set integrated_ek   [integrate_field -materials $semiconductors -plot $cut_plot($i) -geom $cutplane -field Ek   ]
          lappend ek   [expr $integrated_ek / $integrated_dens] 
        }
      }

##    Cleanup cutplane plots
      remove_plots $cut_plot($i)
    }

##  Create output data file names - one for each thing we extract

    if { $foundPot } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_MC_potential.csv w]
      puts $outfile "Position, ${prefix}ElectrostaticPotential"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $pot $i]" }
      close $outfile
    }

    if { $foundBE } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_MCConductionBandEnergy.csv w]
      puts $outfile "Position, ConductionBandEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $cbe $i]" }
      close $outfile

      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_MCValenceBandEnergy.csv w]
      puts $outfile "Position, ValenceBandEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vbe $i]" }
      close $outfile
    }

    if { $foundQEf } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}QuasiFermiEnergy.csv w]
      puts $outfile "Position, ${prefix}QuasiFermiEnergy"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $qef $i]" }
      close $outfile
    }

    if { $foundRho } {
      set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCDensity.csv w]
      puts $outfile "Position, ${prefix}MCDensity"
      for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $dens $i]" }
      close $outfile
    }

    if { $foundBal } {
      if { $foundRho } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCDensityForward.csv w]
        puts $outfile "Position, ${prefix}MCDensityForward"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $densf $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCDensityBackward.csv w]
        puts $outfile "Position, ${prefix}MCDensityBackward"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $densb $i]" }
        close $outfile
      }
      if { $foundVel } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityForward-X.csv w]
        puts $outfile "Position, ${prefix}MCVelocityForward-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vfx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityBackward-X.csv w]
        puts $outfile "Position, ${prefix}MCVelocityBackward-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vbx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityForward-Y.csv w]
        puts $outfile "Position, ${prefix}MCVelocityForward-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vfy $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityBackward-Y.csv w]
        puts $outfile "Position, ${prefix}MCVelocityBackward-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vby $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityForward-Z.csv w]
        puts $outfile "Position, ${prefix}MCVelocityForward-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vfz $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocityBackward-Z.csv w]
        puts $outfile "Position, ${prefix}MCVelocityBackward-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vbz $i]" }
        close $outfile
      }
      if { $foundJ } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentForward-X.csv w]
        puts $outfile "Position, ${prefix}MCCurrentForward-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jfx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentBackward-X.csv w]
        puts $outfile "Position, ${prefix}MCCurrentBackward-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jbx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentForward-Y.csv w]
        puts $outfile "Position, ${prefix}MCCurrentForward-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jfy $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentBackward-Y.csv w]
        puts $outfile "Position, ${prefix}MCCurrentBackward-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jby $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentForward-Z.csv w]
        puts $outfile "Position, ${prefix}MCCurrentForward-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jfz $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrentBackward-Z.csv w]
        puts $outfile "Position, ${prefix}MCCurrentBackward-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jbz $i]" }
        close $outfile
      }
      if { $foundEk } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCEkForward.csv w]
        puts $outfile "Position, ${prefix}MCEkForward"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $ekf $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCEkBackward.csv w]
        puts $outfile "Position, ${prefix}MCEkBackward"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $ekb $i]" }
        close $outfile
      }
    } {
      if { $foundVel } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocity-X.csv w]
        puts $outfile "Position, ${prefix}MCVelocity-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocity-Y.csv w]
        puts $outfile "Position, ${prefix}MCVelocity-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vy $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCVelocity-Z.csv w]
        puts $outfile "Position, ${prefix}MCVelocity-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $vz $i]" }
        close $outfile
      }
      if { $foundJ } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrent-X.csv w]
        puts $outfile "Position, ${prefix}MCCurrent-X"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jx $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrent-Y.csv w]
        puts $outfile "Position, ${prefix}MCCurrent-Y"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jy $i]" }
        close $outfile

        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCCurrent-Z.csv w]
        puts $outfile "Position, ${prefix}MCCurrent-Z"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $jz $i]" }
        close $outfile
      }
      if { $foundEk } {
        set outfile [open n@node@_Vd${Vd}_Vg${Vg}_${prefix}MCEk.csv w]
        puts $outfile "Position, ${prefix}MCEk"
        for {set i 0} {$i < [llength $pos]} {incr i} { puts $outfile "[lindex $pos $i], [lindex $ek $i]" }
        close $outfile
      }
    }

##  If there is ballistic information available, extract the virtual source based on the conduction/valence band energy.
##  Then use the integrated current density to estimate the ballisticty ratio

    if { $foundBal } {

#if "@Type@" == "nMOS"
      ##set band_edge [list $cbe]
      create_variable -name be -dataset EMCl -values $cbe
      echo " - writing cbe:"
      echo $cbe
#elseif "@Type@" == "pMOS"
      ##set band_edge [list $vbe]
      create_variable -name be -dataset EMCl -values $vbe
      echo " - writing vbe:"
      echo $vbe
#endif

      create_variable -name ps -dataset EMCl -values $pos

      set PLOTNAME MC-Results
      create_plot -1d -name $PLOTNAME
      create_curve -name bd_pos -plot $PLOTNAME -dataset EMCl -axisX "ps" -axisY "be"
#if "@Type@" == "pMOS"
      set_curve_prop -plot $PLOTNAME {bd_pos} -yScale -1
#endif

      create_curve -name deriv1 -function diff(<bd_pos>)
      create_curve -name deriv2 -function diff(<deriv1>)

      echo " - writing bd_pos:"
      puts [get_curve_data bd_pos -axisX]
      puts [get_curve_data bd_pos -axisY]

      echo " - writing deriv1:"
      puts [get_curve_data deriv1 -axisY]

      echo " - writing deriv2:"
      puts [get_curve_data deriv2 -axisY]

      set  pos [get_curve_data bd_pos -axisX]
      set  dV  [get_curve_data deriv1 -axisY]
      set  dV2 [get_curve_data deriv2 -axisY]

      export_curves -plot $PLOTNAME {bd_pos} -filename bd_pos_n@node@_GarandMC.plx -format plx -overwrite
      export_curves -plot $PLOTNAME {deriv1} -filename deriv1_n@node@_GarandMC.plx -format plx -overwrite
      export_curves -plot $PLOTNAME {deriv2} -filename deriv2_n@node@_GarandMC.plx -format plx -overwrite

      set N   [llength $dV]
      set mid [expr ($N/2)]

##    Find first turning point (maximum) in band edge
      set i $mid
      set vs_index $mid

      while {$i >= 0} {
        set j  [expr ($i +1)]
        set X1 [lindex $dV $i]
        set X2 [lindex $dV $j]
        echo "$X1 $X2"
        if {[expr ($X1*$X2)] < 0} {
          set dX [lindex $dV2 $i]
          if { $dX < 0} {
            echo "Found root $i"
            set vs_index $i
            set i 0
          }
        }
        incr i -1
      }

##    As backup, if no turning points, find minimum derivative (approximate T.P.)
      if {$vs_index == $mid} {

        set dvdx_min [expr abs([lindex $dV $mid])]

        set i $mid
        while {$i >= 0} {
          set X [lindex $dV $i]
          if {abs($X) < $dvdx_min} {
            set dvdx_min [expr abs($X)]
            set vs_index [expr ($i + 1)]
          }
          incr i -1
        }
      }

      set X [lindex $pos $vs_index]

      echo "vs_index $vs_index"
      echo "x        $X"

      set vs [lindex $pos $vs_index]
      if {$foundJ} {
        set Iplus  [lindex $jf$chan_dir $vs_index]
        set Iminus [lindex $jb$chan_dir $vs_index]
      } else {
        echo "No current density field found in MC output .tdr"
        set Iplus 1.0
        set Iminus 1.0
      }

      echo "================================"
      echo " Ballisticity coefficient"
      echo "I- $Iminus"
      echo "I+ $Iplus"
      set r  [expr (abs($Iminus)/abs($Iplus))]
      echo "r $r"
      set b  [expr ((1.0 - $r)/(1.0 + $r)) ]
      echo "(1-r)/(1+r) $b"

      puts "DOE: virtual_source $vs"
      puts "DOE: Ballisticity $b"

##    Ballisticity at user-defined "virtual source"

      set vs -0.011
      echo "================================"
      echo "At user-defined virtual source $vs \[um\]"
      set i [expr {round(($vs-$start_pos)*@num_slices@/($end_pos-$start_pos))}]
      set Iplus  [lindex $jf$chan_dir $i]
      set Iminus [lindex $jb$chan_dir $i]
      set r      [expr (abs($Iminus)/abs($Iplus))]
      set b      [expr ((1.0 - $r)/(1.0 + $r))]
      echo "r $r"
      echo "(1-r)/(1+r) $b"

##    Write balisticity coefficient as function of position

      set ball [list]
      for {set i 0} {$i <= @num_slices@} {incr i} {
        set Iplus  [lindex $jf$chan_dir $i]
        set Iminus [lindex $jb$chan_dir $i]
        set r      [expr (abs($Iminus)/abs($Iplus))]
        set b      [expr ((1.0 - $r)/(1.0 + $r))]
        lappend ball  $b
      }

      create_variable -name ballisticity -dataset EMCl -values $ball
      create_curve    -name ballisticity -plot $PLOTNAME -dataset EMCl -axisX "ps" -axisY "ballisticity"
      export_curves   -plot $PLOTNAME {ballisticity} -filename n@node@_GarandMC_ballisticity.plx -format plx -overwrite
    }

##  Write position and weighted fields to data files

#   cleanup plots
    remove_plots $plot

    unset pos
    unset dens
    unset pot

    if { $foundBal } {
      unset densf
      unset densb
      unset vfx
      unset vbx
      unset vfy
      unset vby
      unset vfz
      unset vbz
      unset jfx
      unset jbx
      unset jfy
      unset jby
      unset jfz
      unset jbz
      unset ekf
      unset ekb
    } {
      unset vx
      unset vy
      unset vz
      unset jx
      unset jy
      unset jz
      unset ek
    }
} {
    puts "MC FILE DOES NOT EXIST"
}



