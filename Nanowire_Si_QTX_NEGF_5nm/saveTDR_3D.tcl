namespace eval SaveTDR_3D {

    ################################################
    ###--- Save the simulation output results ---###

    # Save 3D TDR
    Save tdrFile=${pid}_qtx.tdr \
	models=[list VacuumPotential DopingConcentration eDensity hDensity \
		    ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy LatticeTemperature]

}

