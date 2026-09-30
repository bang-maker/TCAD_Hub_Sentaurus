namespace eval SaveTDR3D {

################################################
###--- Save the simulation output results ---###

# Save 3D TDR
Save tdrFile=${pid}_bte.tdr \
     models=[list VacuumPotential DopingConcentration eDensity hDensity \
                  ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy ]

set ResultsList [list ]
lappend ResultsList CurrentSpectrum DensitySpectrum DOS
foreach v $valleys {
 set vout1 "${v}_DensitySpectrum"
 lappend ResultsList $vout1 
 for {set i 0} {$i < $PlotNsubbands} {incr i} {
  set suboutv1 "${v}_${i}_DistributionFunction"
  set suboutv2 "${v}_${i}_CurrentSpectrum"
  set suboutv3 "${v}_${i}_DensitySpectrum"
  set suboutv4 "${v}_${i}_DOS"
  set suboutv5 "${v}_${i}_SubbandEnergy"
  lappend ResultsList $suboutv1 $suboutv2 $suboutv3 $suboutv4 $suboutv5
 }
}
# Save Fields over ChannelCoord-Energy
BTESaveE tdrFile=${pid}_bte_CC_E.tdr models=$ResultsList

set ResultsList [list ]
foreach v $valleys {
 for {set i 0} {$i < $PlotNsubbands} {incr i} {
  set outv "${v}_${i}_DistributionFunction"
  lappend ResultsList $outv
 }
}
# Save Distr. Func. over ChannelCoord-k
BTESaveK tdrFile=${pid}_bte_CC_K.tdr models=$ResultsList

set ResultsList [list ]
lappend ResultsList NinvTotal CurrentTotal VelocityTotal Efleq DopingConcentration
foreach v $valleys {
 for {set i 0} {$i < $PlotNsubbands} {incr i} {
  set suboutv1 "${v}_${i}_SubbandEnergy"
  set suboutv2 "${v}_${i}_Ninv"
  set suboutv3 "${v}_${i}_Current"
  set suboutv4 "${v}_${i}_Velocity"
  set suboutv5 "${v}_${i}_Occupancy"
  set suboutv6 "${v}_${i}_Efeq"
  lappend ResultsList $suboutv1 $suboutv2 $suboutv3 $suboutv4 $suboutv5 $suboutv6
 }
}
# Save subband quantities over cc
BTESaveCC tdrFile=${pid}_bte_CC.tdr models=$ResultsList

}

