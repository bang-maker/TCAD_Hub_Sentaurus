#setdep @node|-1@

#set SxxFin    x
#set SyyFin    x
#set SzzFin    x

set infile    "n@node|-1@_tec.out"
set strSource ""

proc mainFunction { aFile astrSource } {

  set tVar "Sxx"
  set tTag "Integral_StressELXX"
  set tSxxList [collectData $aFile $tVar $tTag]

  set tVar "Syy"
  set tTag "Integral_StressELYY"
  set tSyyList [collectData $aFile $tVar $tTag]

  set tVar "Szz"
  set tTag "Integral_StressELZZ"
  set tSzzList [collectData $aFile $tVar $tTag]

  set tV     [expr (@<1.0*L*0.5*(Wtop+Wbottom)*H>@*1.0e-12*1.0e-2*1.0e6)]
puts "Fin Volume = $tV"  
  set tSx    [lindex $tSxxList 0]
  set tSy    [lindex $tSyyList 0]
  set tSz    [lindex $tSzzList 0]
  set tSx    [expr ($tSx/$tV)]
  set tSy    [expr ($tSy/$tV)]
  set tSz    [expr ($tSz/$tV)]
  puts -nonewline "DOE: SxxFin " ; puts [format "%.0f" $tSx]
  puts -nonewline "DOE: SyyFin " ; puts [format "%.0f" $tSy]
  puts -nonewline "DOE: SzzFin " ; puts [format "%.0f" $tSz]
}


proc collectData { aFile aVar aTag } {

  set FIDr [open $aFile "r"]

  set tData [list]
  while { [gets $FIDr NewLine] >= 0 } {

    if { [regexp {^DOE:} $NewLine] } {

      set tlist [split $NewLine]

      if { [llength $tlist] < 3 } {

        puts "Wrong formation.."
        puts "  $NewLine"
        exit
      }

      if { [string compare $aTag [lindex $tlist 1]] == 0 } {

        set tAve [lindex $tlist 2]
        lappend tData $tAve

      }
    }
  }
  close $FIDr

  return $tData
}

mainFunction $infile $strSource


