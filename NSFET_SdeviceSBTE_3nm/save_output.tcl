
proc output {file_prefix} {

 upvar valleys      valleys
 upvar Nsubbands    Nsubbands
 upvar Zc           Zc

 AddToLogFile name=Id value=[GetLast name=I(drain)]

 Save tdrFile=${file_prefix}_bte.tdr \
      models=[list VacuumPotential eDensity hDensity DopingConcentration \
              ConductionBandEnergy ValenceBandEnergy eQuasiFermiPotential hQuasiFermiPotential]

 set models {}
 lappend models CurrentSpectrum DensitySpectrum DOS
 foreach valley $valleys {
  for {set subband 0} {$subband < $Nsubbands} {incr subband} {
   lappend models ${valley}_${subband}_DistributionFunction 
   lappend models ${valley}_${subband}_CurrentSpectrum 
   lappend models ${valley}_${subband}_DensitySpectrum 
   lappend models ${valley}_${subband}_SubbandEnergy 
   lappend models ${valley}_${subband}_DOS
  }
 }
 BTESaveE tdrFile=${file_prefix}_bte_CC_E.tdr models=$models

 set models {}
 foreach valley $valleys {
  for {set subband 0} {$subband < $Nsubbands} {incr subband} {
    lappend models ${valley}_${subband}_DistributionFunction
  }
 }
 BTESaveK tdrFile=${file_prefix}_bte_CC_K.tdr models=$models

 set models {}
 foreach valley $valleys {
  for {set subband 0} {$subband < $Nsubbands} {incr subband} {
    lappend models ${valley}_${subband}_Occupancy
    lappend models ${valley}_${subband}_Ninv
    lappend models ${valley}_${subband}_Current
    lappend models ${valley}_${subband}_Velocity
    lappend models ${valley}_${subband}_SubbandEnergy
    lappend models ${valley}_${subband}_Efeq
  }
 }
 lappend models NinvTotal CurrentTotal VelocityTotal Efleq DerivativeEfleq DopingConcentration
 BTESaveCC tdrFile=${file_prefix}_bte_CC.tdr models=$models

 set models {eDensity hDensity}
 foreach valley $valleys {
  for {set subband 0} {$subband < $Nsubbands} {incr subband} {
   lappend models ${valley}_${subband}_Wavefunction
  }
 }
 SaveSlice tdrFile=${file_prefix}_bte_SliceMiddle.tdr  channelCoord=$Zc models=$models

 set models {}
 foreach valley $valleys {
  for {set subband 0} {$subband < $Nsubbands} {incr subband} {
   lappend models ${valley}_${subband}_Dispersion
  }
 }
 SaveSliceK tdrFile=${file_prefix}_bte_SliceKMiddle.tdr channelCoord=$Zc models=$models

}


