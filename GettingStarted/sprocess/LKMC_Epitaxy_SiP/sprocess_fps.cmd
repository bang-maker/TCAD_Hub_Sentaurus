
SetAtomistic

AdvancedCalibration



# keep from inject I and V
pdbSet Gas_Silicon   KMC Model Reflective
pdbSet Gas_Germanium KMC Model Reflective


############################################################################################################

pdbSet KMC Epitaxy true

pdbSet LKMC Epitaxy.Model @model@

pdbSet LKMC Epitaxy.Cleanup 0

###################################################################################################################

pdbSet KMC Simplify.Geometry 1e-4
pdbSet KMC Movie ""

pdbSet KMC MaxYum 20e-3
pdbSet KMC MaxZum 20e-3


          
## enough gas
line x loc=-0.2    spac=0.001
line x loc= 0.0    spac=0.001   tag=top
line x loc= 0.05   spac=0.002
line x loc= 0.1    spac=0.002   tag=bot
region @Mat@ xlo=top xhi=bot

init wafer.orient= { @Wafer@ } !DelayFullD 


set epitime @time@

gas_flow  name= SiP    epi flowHGas=@H2@ flowDichlorosilane=@DCS@ flowPhosphine=@PH3@ pressure= @torr@<torr>
temp_ramp name= SiPEpi gas.flow= SiP epi.model=1 time= [expr $epitime] temp=@temp@ 


diffuse temp.ramp=SiPEpi info=0


struct tdr=n@node@_epi

deposit material = {Oxide} type = isotropic  rate = {1.0} time=0.001


struct tdr=n@node@

exit


