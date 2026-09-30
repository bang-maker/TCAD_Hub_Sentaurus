namespace eval Math {

if { $sign == 1 } {
# n-type 

#- set valleys [list Delta1 Delta2 Delta3] 
 # Setup Parabolic Schro on the sliced channel
 Physics slicedChannel=channel1 eSchrodinger=Parabolic valleys=$valleys \
         Nsubbands=$Nsubbands Nk=16 Kmax=0.6 a0=5.43e-8 correction=3
         
 # Select BTE solver and set some energy grid paramters; tau=1.0e-10
 Physics slicedChannel=channel1 eBTESolver=Numeric deltaE=4.0e-3 resolveTOBEnergy=1 \
         minDeltaE=1.0e-4 tau=1.0e-10 
} else {
# p-type 

#- set valleys [list Gamma]
 # Setup 6kp Schro
 set kGrid [list 0.00E+00 8.35E-03 1.67E-02 2.50E-02 3.33E-02 5.00E-02 6.67E-02 8.33E-02 0.1 \
                 0.116666667 0.133333333 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6]
 Physics slicedChannel=channel1 hSchrodinger=6kp valleys=$valleys \
         Nsubbands=$Nsubbands kGrid=$kGrid a0=5.43e-8 useKdependentWF=1 \
         degenSubbandEnergySplit=1.0e-6

 # Select BTE solver and set some energy grid paramters; default tau=1.0e-10
 Physics slicedChannel=channel1 hBTESolver=Numeric deltaE=4.0e-3 resolveTOBEnergy=1 \
         minDeltaE=1.0e-4 tau=1.0e-10 
}

# Set some convergence params. We will continue to next bias if not-converged
Math potentialUpdateTolerance=1.0e-2 iterations=30 doOnFailure=0

}

