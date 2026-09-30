namespace eval PhysicsBand {

#-------------------------------------#
#--- Silicon parameters definition ---#
#-------------------------------------#
# Silicon electrical parameters
Physics material=Silicon Permittivity               epsilon=11.7
Physics material=Silicon Affinity                   chi=4.0727
Physics material=Silicon Bandgap                    Eg=1.1242

# Set compliance tensor components
Elasticity name=E type=Cubic s11=0.762451 s12=-0.213158 s44=1.25;    # Si units are %/GPa

# Use simple Bulk carrier density models 
Physics material=Silicon eBulkDensity=eFermiDensity Nc=2.8567e19
Physics material=Silicon hBulkDensity=hFermiDensity Nv=3.1046e19

# CarrierType specific setup
if { $sign == 1 } {
 Physics material=Silicon hDensity=ConstantModel value=0.0; # suppress holes for nmos
} else {
 Physics material=Silicon eDensity=ConstantModel value=0.0; # suppress electrons for pmos
}

set alpha_si 0.5; set ml_si    0.916; set mt_si    0.190;
Physics material=Silicon ValleyModel=2kpEllipsoid name=Delta1 useForEBulkDensity=1  \
        longAxis=100 degeneracy=2 ml=$ml_si mt=$mt_si M=1.2 Eshift=0.0 alpha=$alpha_si
Physics material=Silicon ValleyModel=2kpEllipsoid name=Delta2 useForEBulkDensity=1  \
        longAxis=010 degeneracy=2 ml=$ml_si mt=$mt_si M=1.2 Eshift=0.0 alpha=$alpha_si
Physics material=Silicon ValleyModel=2kpEllipsoid name=Delta3 useForEBulkDensity=1  \
        longAxis=001 degeneracy=2 ml=$ml_si mt=$mt_si M=1.2 Eshift=0.0 alpha=$alpha_si
Physics material=Silicon ValleyModel=6kpValley name=Gamma useForHBulkDensity=0 \
        degeneracy=1 gamma1=4.27 gamma2=0.315 gamma3=1.3867 delta=0.044 \
        a_v=2.1 b=-2.2 d=-5.3 a0=5.43e-8
#-------------------------------------------------------------------------------------------#


#-----------------------------------#
#--- Oxide parameters definition ---#
#-----------------------------------#
Physics material=Oxide Permittivity  epsilon=3.9
Physics material=Oxide Affinity      chi=0.9
Physics material=Oxide Bandgap       Eg=9.0

# Setup NetDensity in Oxide for charge from oxide penentration to be included in Poisson
# For nodes on slices, eDensity will get replaced by interp from {e|h} NEGFDensity
Physics material=Oxide eDensity=eHybridDensity
Physics material=Oxide hDensity=hHybridDensity
Physics material=Oxide eBulkDensity=ConstantModel value=0.0
Physics material=Oxide hBulkDensity=ConstantModel value=0.0
Physics material=Oxide DopingConcentration=ConstantModel value=0.0
Physics material=Oxide NetDensity=StandardNetDensity

# Setup Delta and Gamma valleys in oxide for wavefunction penetration
set alpha_ox 1.0e-3; set m_ox     0.5;
Physics material=Oxide ValleyModel=ConstantEllipsoid name=Delta1 degeneracy=2 \
        ml=$m_ox mt1=$m_ox mt2=$m_ox alpha=$alpha_ox 
Physics material=Oxide ValleyModel=ConstantEllipsoid name=Delta2 degeneracy=2 \
        ml=$m_ox mt1=$m_ox mt2=$m_ox alpha=$alpha_ox 
Physics material=Oxide ValleyModel=ConstantEllipsoid name=Delta3 degeneracy=2 \
        ml=$m_ox mt1=$m_ox mt2=$m_ox alpha=$alpha_ox 
Physics material=Oxide ValleyModel=6kpValley         name=Gamma  degeneracy=1 \
        gamma1=2.0 gamma2=0.0 gamma3=0.0 delta=0.044 
#-------------------------------------------------------------------------------------------#

#----------------------------------#
#--- LowK parameters definition ---#
#----------------------------------#
Physics material=LowK Permittivity  epsilon=2.5
Physics material=LowK Affinity      chi=0.9
Physics material=LowK Bandgap       Eg=9.0

# Setup NetDensity in LowK for charge from LowK penentration to be included in Poisson
# For nodes on slices, eDensity will get replaced by interp from {e|h} NEGFDensity
Physics material=LowK eDensity=eHybridDensity
Physics material=LowK hDensity=hHybridDensity
Physics material=LowK eBulkDensity=ConstantModel value=0.0
Physics material=LowK hBulkDensity=ConstantModel value=0.0
Physics material=LowK DopingConcentration=ConstantModel value=0.0
Physics material=LowK NetDensity=StandardNetDensity

# Setup Delta and Gamma valleys in LowK for wavefunction penetration
set alpha_lk 1.0e-3; set m_lk     0.5;
Physics material=LowK ValleyModel=ConstantEllipsoid name=Delta1 degeneracy=2 \
        ml=$m_lk mt1=$m_lk mt2=$m_lk alpha=$alpha_lk 
Physics material=LowK ValleyModel=ConstantEllipsoid name=Delta2 degeneracy=2 \
        ml=$m_lk mt1=$m_lk mt2=$m_lk alpha=$alpha_lk 
Physics material=LowK ValleyModel=ConstantEllipsoid name=Delta3 degeneracy=2 \
        ml=$m_lk mt1=$m_lk mt2=$m_lk alpha=$alpha_lk 
Physics material=LowK ValleyModel=6kpValley         name=Gamma  degeneracy=1 \
        gamma1=2.0 gamma2=0.0 gamma3=0.0 delta=0.044 
#-------------------------------------------------------------------------------------------#

}
