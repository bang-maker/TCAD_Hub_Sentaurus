namespace eval MathNEGF {

    if { $sign == 1 } {
	# n-type 

	# Setup Parabolic Schroedinger on the nonlocal
	Physics nonlocal=channel1 eSchrodinger=Parabolic valleys=$valleys
	
	# Select NEGF solver and set some parameters
	set Nbands [expr $Nmodes-4]
	if {[string compare $Scattering Ballistic]==0 } {
	    puts "Running Ballistic EMA NEGF simulation \n"
	    Physics nonlocal=channel1 eNEGFSolver=BallisticGF \
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.141593\
		msSolver=0 msNk=1 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=1.0e-3 dEout=2.0e-3\
		dEsep=5.0e-4 NEmax=2500
		
		## Set some convergence params. Simulation continues to next bias if not-converged
		Math potentialUpdateTolerance=2.5e-2 potentialUpdateClamp=0.3\
		iterations=50 doOnFailure=0 maxInnerIter=15
		
	    Solve V(gate)=0.0  V(drain)=[expr 0.5*$Vdrain]
	    
	} else {
	    puts "Running Ballistic EMA NEGF simulation for a good initial guess\n"
	    Physics nonlocal=channel1 eNEGFSolver=BallisticGF \
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.141593\
		msSolver=0 msNk=1 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=1.0e-3 dEout=2.0e-3\
		dEsep=5.0e-4 NEmax=2500 

	    # Set some convergence params. We will continue to next bias if not-converged
	    Math potentialUpdateTolerance=1.0e-2 potentialUpdateClamp=0.3\
		iterations=50 doOnFailure=0

	    Solve V(gate)=0.0  V(drain)=[expr 0.5*$Vdrain]
		Solve V(gate)=0.0  V(drain)=$Vdrain

	    puts "Running Scattering EMA NEGF simulation \n"
	    Physics nonlocal=channel1 eNEGFSolver=ScatteringGF\
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.14159265\
		msSolver=0 msNk=1 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=5.0e-4 dEout=1.0e-3\
		dEsep=2.5e-4 NEmax=2500 scattIncInj=1 scattDensTol=0.005 scattBornIterMax=100 
		
		## Set some convergence params. Simulation continues to next bias if not-converged
		Math potentialUpdateTolerance=2.0e-2 potentialUpdateClamp=0.3\
		iterations=$iterations doOnFailure=0 maxInnerIter=15
	}
    } else {
	# p-type 

	# Setup 6kp Schroedinger
	Physics nonlocal=channel1 hSchrodinger=6kp valleys=$valleys \
	    degenSubbandEnergySplit=1.0e-6

	# Select NEGF solver and set some parameters
	set Nbands [expr $Nmodes-4]
	if {[string compare $Scattering Ballistic]==0 } {
	    puts "Running Ballistic KP NEGF simulation \n"
	    Physics nonlocal=channel1 hNEGFSolver=BallisticGF \
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.141593\
		msSolver=0 msNk=5 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=1.0e-3 dEout=2.0e-3\
		dEsep=5.0e-4 NEmax=2500
		
		## Set some convergence params. Simulation continues to next bias if not-converged
		Math potentialUpdateTolerance=2.5e-2 potentialUpdateClamp=0.3\
		iterations=50 doOnFailure=0 maxInnerIter=15
		
	    Solve V(gate)=0.0  V(drain)=[expr 0.5*$Vdrain]
	    
	} else {

	    puts "Running Ballistic KP NEGF simulation for a good initial guess\n"
	    Physics nonlocal=channel1 hNEGFSolver=BallisticGF \
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.141593\
		msSolver=0 msNk=5 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=1.0e-3 dEout=2.0e-3\
		dEsep=5.0e-4 NEmax=2500 eta=1.0e-12

	    # Set some convergence params. We will continue to next bias if not-converged
	    Math potentialUpdateTolerance=1.0e-2 potentialUpdateClamp=0.3\
		iterations=50 doOnFailure=0

	    Solve V(gate)=0.0  V(drain)=[expr 0.5*$Vdrain]

	    puts "Running Scattering KP NEGF simulation \n"
	    Physics nonlocal=channel1 hNEGFSolver=ScatteringGF\
		contactEkSolver=0 contactEkNM=$Nbands contactEkNk=51 contactEkKmax=3.14159265\
		msSolver=0 msNk=5 msNM=$Nmodes msKmin=0.0 msKmax=1.6\
		Elimit=50.0e-3 Eoffset=0.7 EminTail=4.0e-3 dEin=1.0e-3 dEout=1.0e-3\
		dEsep=5.0e-4 NEmax=2500 scattIncInj=1 scattDensTol=0.005 scattBornIterMax=100
		
		## Set some convergence params. Simulation continues to next bias if not-converged
		Math potentialUpdateTolerance=2.0e-2 potentialUpdateClamp=0.3\
		iterations=10 doOnFailure=0 maxInnerIter=15
		
		Solve V(gate)=0.0  V(drain)=[expr 0.5*$Vdrain]
		
		## Set some convergence params. Simulation continues to next bias if not-converged
		Math potentialUpdateTolerance=2.0e-2 potentialUpdateClamp=0.3\
		iterations=$iterations doOnFailure=0 maxInnerIter=15
	}
    }
    
}

