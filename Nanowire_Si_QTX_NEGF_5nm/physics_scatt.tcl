namespace eval PhysicsScatt {
    
  if {[string compare $scatteringEvent PH]==0} {

	puts "Scattering: Enabling phonon scattering"

	##-----------------------##
	##-- Phonon Scattering --##
	##-----------------------##
	##-- Electron Phonon Scattering --##
	## Acoustic Phonon ##
	set massDensity 2.33
	set ul 9.05e5
	set Dac 14.0

	Physics material=Silicon ScatteringModel=ElasticAcousticPhonon name=ElectronAC \
	    transitionType=Intravalley valleys=$valleys \
	    density=$massDensity ul=$ul Dac=$Dac

	## Inter-valley Inelastic Phonon ##
	set kb          8.617343e-5
	set massDensity 2.33
	set phononList [list [list ivf1  0.3e8 [expr $kb*220] ] \
			    [list ivf2  2.0e8 [expr $kb*550] ] \
			    [list ivf3  2.0e8 [expr $kb*685] ] \
			    [list ivg1  0.5e8 [expr $kb*140] ] \
			    [list ivg2  0.8e8 [expr $kb*215] ] \
			    [list ivg3 11.0e8 [expr $kb*720] ]]

	foreach triplet $phononList {
	    set name [lindex $triplet 0]
	    set DtK  [lindex $triplet 1]
	    set hw   [lindex $triplet 2]
	    if { [string first f $name]!=-1 } {
	    	set ttype Intervalley		
	    	set inter_valleys [list {Delta1 Delta2} {Delta1 Delta3} {Delta2 Delta1} {Delta2 Delta3} \
				       {Delta3 Delta1} {Delta3 Delta2}]
	    } else {
	    	set ttype gIntervalley
	    	set inter_valleys $valleys
	    }

	    foreach itype [list ABS EMS] {
		Physics material=Silicon ScatteringModel=InelasticPhonon name="${name}_${itype}" \
		    transitionType=$ttype inelasticType=$itype valleys=$inter_valleys \
		    hbarOmega=$hw DtK=$DtK density=$massDensity
	    }
	}; # end loop over inelastic transitions

	##-- Hole Phonon Scattering --##
	## Acoustic Phonon ##
	set massDensity 2.33
	set ul 9.05e5
	set Dac 10.2
	Physics material=Silicon ScatteringModel=ElasticAcousticPhonon name=HoleAC \
	    transitionType=Intravalley valleys=$valleys \
	    Dac=$Dac density=$massDensity ul=$ul kdepFF=1

	set massDensity 2.33
	set DtK         15.0e8 
	set hw          62.0e-3
	## Optical Phonon, absorption mode ##
	Physics material=Silicon ScatteringModel=InelasticPhonon name=OP_ABS \
	    transitionType=Intravalley inelasticType=ABS valleys=$valleys \
	    hbarOmega=$hw DtK=$DtK density=$massDensity kdepFF=1
	## Optical Phonon, emission mode ##
	Physics material=Silicon ScatteringModel=InelasticPhonon name=OP_EMS \
	    transitionType=Intravalley inelasticType=EMS valleys=$valleys \
	    hbarOmega=$hw DtK=$DtK density=$massDensity kdepFF=1
  }
  ##----------------------------------------------------------------------------------------##

  if {[string compare $scatteringEvent SR]==0} {

	puts "Scattering: Enabling surface roughness scattering"

	##---------------------------------##
	##-- SurfaceRoughness Scattering --##
	##---------------------------------##
	Physics material=Silicon ScatteringModel=SRFor2D name=ElectronSR \
	    transitionType=Intravalley valleys=$valleys \
	    delta=[list {100 0.4e-7} {110 0.52e-7}] lambda=1.2e-7 powerSpectrum=Exponential beta=1.5\
	    screening=ThomasFermi 


	Physics material=Silicon ScatteringModel=SRFor2D name=HoleSR \
	    transitionType=Intravalley valleys=$valleys \
	    delta=[list {100 0.25e-7}] lambda=4.0e-7 powerSpectrum=Exponential beta=1.5\
	    screening=ThomasFermi 
  }
  ##----------------------------------------------------------------------------------------##

  if {[string compare $scatteringEvent CO]==0} {

	puts "Scattering: Enabling Coulomb scattering"

	##---------------------------------##
	##-- Coulomb Scattering --##
	##---------------------------------##
	Physics material=Silicon ScatteringModel=Coulomb name=ElectronCO \
	    transitionType=Intravalley valleys=$valleys screening=ThomasFermi whenToCompute=FirstIteration
	Physics material=Silicon ScatteringModel=Coulomb name=HoleCO \
	    transitionType=Intravalley valleys=$valleys screening=ThomasFermi whenToCompute=FirstIteration
  }
  ##----------------------------------------------------------------------------------------##
}

