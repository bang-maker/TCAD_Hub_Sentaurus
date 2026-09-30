# Copyright (c) 1994-2020 Synopsys, Inc.
# This file and the associated documentation are proprietary to
# Synopsys, Inc.  This file may only be used in accordance with the
# terms and conditions of a written license agreement with Synopsys,
# Inc.  All other use, reproduction, or distribution of this file is
# strictly prohibited.



proc tcl_cp_constructor { } {
  # link to variables in enclosing namespace
  upvar #1 tcl_cp_adr tcl_cp_adr
  upvar #1 Conductivity_Region Conductivity_Region

  set Conductivity_Region [$tcl_cp_adr InitStringParameter "Conductivity_Region" ""]
}



proc tcl_cp_destructor {} {
}



proc tcl_cp_Compute_Dataset_Names {} {
  upvar #1 Conductivity_Region Conductivity_Region
  lappend result "Tcl_Ave_$Conductivity_Region eConductivity"
  return $result
}



proc tcl_cp_Compute_Function_Names {} {
  lappend result "Conductivity"
  return $result
}



proc tcl_cp_Compute_Plot_Values {} {
  # link to variables in enclosing namespace
  upvar #1 tcl_cp_adr tcl_cp_adr
  upvar #1 Conductivity_Region Conductivity_Region

  set mesh [$tcl_cp_adr Mesh]
  set data [$tcl_cp_adr Data]
  set measure [$data ReadMeasure]

  set q 1.602e-19
  set eDensity [$data ReadScalar $::des_data_vertex "eDensity"]
  set eMobility [$data ReadScalar $::des_data_vertex "eMobility"]

  set sum 0.0
  set sum_m 0.0

  set size_region [$mesh size_region]
  for {set ri 0} {$ri < $size_region} {incr ri} {
    set region [$mesh region $ri]
    if {[$region type] == $::des_region_bulk && \
        [$region name] == $Conductivity_Region} {
      set bulk [tcl_cp_region2bulk $region]
      set size_element [$bulk size_element]
      for {set ei 0} {$ei < $size_element} {incr ei} {
        set element [$bulk element $ei]
        set element_index [$element index]
        set size_vertex [$element size_vertex]
        for {set vi 0} {$vi < $size_vertex} {incr vi} {
          set vertex [$element vertex $vi]
          set vertex_index [$vertex index]

          set n [tcl_cp_get_double $eDensity $vertex_index]
          set mu [tcl_cp_get_double $eMobility $vertex_index]
          set value [expr "$q * $n * $mu"]

          set m [tcl_cp_get_double2 $measure $element_index $vi]
          set sum [expr "$sum + $m * $value"]
          set sum_m [expr "$sum_m + $m"]
        }
      }
    }
  }

  if {$sum_m == 0} {
    set average 0
  } else {
    set average [expr "$sum / $sum_m"]
  }

  lappend result $average
}
