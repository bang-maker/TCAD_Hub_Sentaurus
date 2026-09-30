namespace eval SaveTDR2D {

################################################
###--- Save the simulation output results ---###

set ResultsList [list ]
lappend ResultsList eDensity hDensity ConductionBandEnergy ValenceBandEnergy
foreach v $valleys {
 for {set i 0} {$i < $PlotNsubbands} {incr i} {
  set outv0 "${v}_${i}_Wavefunction"
  set outv1 "${v}_${i}_SubbandEnergy"
  lappend ResultsList $outv0 $outv1
 }
}
# Save fields over a slice
SaveSlice tdrFile=${pid}_bte_Slice.tdr  channelCoord=$cutX \
          models=$ResultsList

set ResultsList [list ]
foreach v $valleys {
 for {set i 0} {$i < $PlotNsubbands} {incr i} {
  set outv "${v}_${i}_Dispersion"
  lappend ResultsList $outv
 }
}
# Save dispersion at a slice
SaveSliceK tdrFile=${pid}_bte_SliceK.tdr channelCoord=$cutX \
           models=$ResultsList

}

