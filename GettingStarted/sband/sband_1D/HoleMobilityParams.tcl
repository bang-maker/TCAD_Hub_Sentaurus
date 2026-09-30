puts "Using New Hole Mobility Parameters"

# Phonons. Use kdep-FF.        
Physics material=Silicon ScatteringModel name=OP_ABS DtK=15.e8 hbarOmega=62.0e-3 kdepFF=1
Physics material=Silicon ScatteringModel name=OP_EMS DtK=15.e8 hbarOmega=62.0e-3 kdepFF=1
Physics material=Silicon ScatteringModel name=HoleAC Dac=10.2                    kdepFF=1
Math useDonettiOverlapFix=0

# Surface Roughness
Physics material=Silicon ScatteringModel name=HoleSR remove
Physics material=Silicon ScatteringModel=SRFrom6kp name=HoleSR \
        valleys=[list Gamma] transitionType=Intravalley \
        powerSpectrum=Exponential beta=1.5 \
        lambda=40.e-8 delta=2.5e-8 screening=none
        
# Set 6kp parameters
Physics material=Silicon ValleyModel name=Gamma \
        gamma1=4.27 gamma2=0.315  gamma3=1.3867 delta=0.044 a_v=2.1 b=-2.2 d=-5.3 a0=5.43e-8

