proc makeUniformList { start end Nsteps } {
  set step [expr ($end-$start)/($Nsteps-1.)]
  set uniformList [list]
  for {set i 0} {$i<$Nsteps} {incr i} {
    set x [expr $start + $i*$step]
    lappend uniformList $x
  }
  return $uniformList
}


proc getNinv {} {
    return [GetLast name=Ninv_in_well0]
}

proc getElectronEeff {} {
  return [Extract model=eEeffIntegrand region=si1 integral]
}

proc getPinv {} {
    return [GetLast name=Pinv_in_well0]
}

proc getHoleEeff {} {
  return [Extract model=hEeffIntegrand region=si1 integral]
}


# proc to find contact bias so that targetValue computed with targetProc is achieved
# Does bisection to find fermi level that gives proper Ninv. Assume target function is
# a monotonically increasing function of contact bias, e.g. Ninv or Eeff
# For double-gate devices
proc SolveAtTargetDG { contactName1 contactName2 targetValue targetProc carrierType } {

  puts "SolveAtTarget. Target value=$targetValue"

  if { $carrierType=="e"} {
    set sign 1
  } else {
    set sign -1
  }


  # Get most recent Vbias and function value
  set Vbias0 [GetLast name="V(${contactName1})"]
  Solve V(${contactName1})=$Vbias0 V(${contactName2})=$Vbias0
  set value0 [eval $targetProc]

  # Bracket targetValue.
  # Reduce Vbias if necessary
  set Vbias $Vbias0
  set value $value0
  puts "Lower bracket search. value=$value"
  while { $value > $targetValue } {
    set Vbias [expr $Vbias - 0.1*$sign]
    Solve V(${contactName1})=$Vbias V(${contactName2})=$Vbias
    set value [eval $targetProc]
      puts "Lower bracket search. value=[format "%e" $value]"
  }
  set minVbias $Vbias
  set minValue $value

  # Find upper Vbias
  set Vbias $Vbias0
  set value $value0
  while { $value < $targetValue } {
    set Vbias [expr $Vbias + 0.4*$sign]
    Solve V(${contactName1})=$Vbias V(${contactName2})=$Vbias 
    set value [eval $targetProc]
      puts "Upper bracket search. value=[format "%e" $value]"
  }
  set maxVbias $Vbias
  set maxValue $value
  # Now do bisection to find Vbias that gives targetValue
  set relErr 1.0
  while {$relErr>1.0e-3} {
    #set Vbias [expr 0.5*($minVbias+$maxVbias)]; # bisection
    set m [expr ($maxValue-$minValue)/($maxVbias-$minVbias)]; # linear interp
    set Vbias [expr ($targetValue-$minValue)/$m + $minVbias]

    Solve V(${contactName1})=$Vbias V(${contactName2})=$Vbias 
    set value [eval $targetProc]

    if { $value>$targetValue } {
      set maxVbias $Vbias
      set maxValue $value
    } else {
      set minVbias $Vbias
      set minValue $value
    }

    set relErr [expr abs($value/$targetValue-1)]
    puts "Vbias=$Vbias, value=[format "%.5e" $value], error=[format "%e" $relErr]"
  }

  puts "Found Vbias to give targetValue\n\n"
}

# proc to find contact bias so that targetValue computed with targetProc is achieved
# Does bisection to find fermi level that gives proper Ninv. Assume target function is
# a monotonically increasing function of contact bias, e.g. Ninv or Eeff
# For single-gate devices
proc SolveAtTargetSG { contactName targetValue targetProc carrierType } {

  puts "SolveAtTarget. Target value=$targetValue"

  if { $carrierType=="e"} {
    set sign 1
  } else {
    set sign -1
  }


  # Get most recent Vbias and function value
  set Vbias0 [GetLast name="V(${contactName})"]
  Solve V(${contactName})=$Vbias0
  set value0 [eval $targetProc]

  # Bracket targetValue.
  # Reduce Vbias if necessary
  set Vbias $Vbias0
  set value $value0
  puts "Lower bracket search. value=$value"
  while { $value > $targetValue } {
    set Vbias [expr $Vbias - 0.1*$sign]
    Solve V(${contactName})=$Vbias
    set value [eval $targetProc]
      puts "Lower bracket search. value=[format "%e" $value]"
  }
  set minVbias $Vbias
  set minValue $value

  # Find upper Vbias
  set Vbias $Vbias0
  set value $value0
  while { $value < $targetValue } {
    set Vbias [expr $Vbias + 0.4*$sign]
    Solve V(${contactName})=$Vbias
    set value [eval $targetProc]
      puts "Upper bracket search. value=[format "%e" $value]"
  }
  set maxVbias $Vbias
  set maxValue $value
  # Now do bisection to find Vbias that gives targetValue
  set relErr 1.0
  while {$relErr>1.0e-3} {
    #set Vbias [expr 0.5*($minVbias+$maxVbias)]; # bisection
    set m [expr ($maxValue-$minValue)/($maxVbias-$minVbias)]; # linear interp
    set Vbias [expr ($targetValue-$minValue)/$m + $minVbias]

    Solve V(${contactName})=$Vbias
    set value [eval $targetProc]

    if { $value>$targetValue } {
      set maxVbias $Vbias
      set maxValue $value
    } else {
      set minVbias $Vbias
      set minValue $value
    }

    set relErr [expr abs($value/$targetValue-1)]
    puts "Vbias=$Vbias, value=[format "%.5e" $value], error=[format "%e" $relErr]"
  }

  puts "Found Vbias to give targetValue\n\n"
}


proc getIntegratedNetCharge { regionName } {
  set integral [Extract model=NetDensity region=$regionName integral]
  set Q [expr 1.602e-19*$integral]
  return $Q
}



