namespace eval SaveTDR_NEGF {

    ################################################
    ###--- Save the simulation output results ---###

    set ResultsList [list ]
    if {[string compare $scatteringEvent Ballistic]==0} {
    	lappend ResultsList CurrentSpectrum DensitySpectrum DOS
    } else {
    	lappend ResultsList CurrentSpectrum DensitySpectrum
    }
    foreach v $valleys {
	set vout1 "${v}_DensitySpectrum"
	set vout2 "${v}_CurrentSpectrum"
	if {[string compare $scatteringEvent Ballistic]==0} {
		set vout3 "${v}_DOS"
		lappend ResultsList $vout1 $vout2 $vout3
    } else {
    	lappend ResultsList $vout1 $vout2
	}
    }
    # Save Fields over ChannelCoord-Energy
    NEGFSaveE tdrFile=${pid}_negf_CC_E.tdr models=$ResultsList

    set ResultsList [list ]
    lappend ResultsList NinvTotal CurrentTotal VelocityTotal DopingConcentration LatticeTemperature
    foreach v $valleys {
	set vout1 "${v}_Ninv"
	set vout2 "${v}_Current"
	set vout3 "${v}_Velocity"
	lappend ResultsList $vout1 $vout2 $vout3 
	for {set i 0} {$i < $PlotNsubbands} {incr i} {
	    set suboutv1 "${v}_${i}_SubbandEnergy"
	    lappend ResultsList $suboutv1
	}
    }
    # Save subband quantities over cc
    NEGFSaveCC tdrFile=${pid}_negf_CC.tdr models=$ResultsList

}

