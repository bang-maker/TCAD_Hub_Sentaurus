#if [string compare @calibration@ "on"] == 0
source  @pwd@/calibration.fps
#endif

pdbSet ImplantData UseCoImplant 0

#--- Grid ------------------------------------------------------------
line  x location= 0     spacing= 1<nm> tag= SiTop       
line  x location= 10<nm> spacing= 2<nm>                
line  x location= 50<nm> spacing= 10<nm>                
line  x location= 0.5<um> spacing= 50<nm>                
line  x location= 10.0<um> spacing=0.2<um> tag= SiBottom   

line  y location= 0     spacing= 50<nm>  tag= Mid
line  y location= 0.5<um> spacing= 50<nm>  tag= Right
    
#--- Silicon substrate definition ------------------------------------
region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right

#--- Start simulation of Process Steps -------------------------------
init  concentration= 1.0E+15<cm-3> field= Boron wafer.orient= 100

#---------------------------------------------------------------------
set        ProcessStepID "PWell Implantation"
#---------------------------------------------------------------------
deposit material= {Oxide} type= isotropic rate= {1.0} time= 0.01

LogFile "Boron IFactor before implant: [pdbGet Silicon Boron IFactor]" 
LogFile "Boron AcInit  before implant: [pdbGetDouble Silicon Boron AcInit]"

implant  Boron dose= 1e12<cm-2> energy= 20<keV> tilt= 0 rotation= 0 info= 2

LogFile "Boron IFactor after implant: [pdbGet Silicon Boron IFactor]" 
LogFile "Boron AcInit  after implant: [pdbGetDouble Silicon Boron AcInit]"

SetPlxList { Boron_Implant Int_Implant }
WritePlx   n@node@_PWellimpl.plx   y=0


#---------------------------------------------------------------------
set       ProcessStepID "PWell RTA"
#---------------------------------------------------------------------
diffuse   time= 1.0e-12<min>   temp= 600<C>

SetPlxList { BTotal BActive ITotal }
WritePlx   n@node@_PWellrta_init.plx   y= 0

temp_ramp name= PWellrta  time= 3.0<s> temperature= 600.0<C> ramprate= 150.0<K/s>
temp_ramp name= PWellrta  time= 0.1<s> temperature= 1050.0<C> 
temp_ramp name= PWellrta  time= 6.0<s> temperature= 1050.0<C> ramprate=-75.0<K/s>
diffuse   temp.ramp= PWellrta  init= 1e-8<min>


etch    material= {Oxide} type= isotropic rate= {1.0} time= 0.015
deposit material= {Oxide} type= isotropic rate= {1.0} time= 0.002

#---------------------------------------------------------------------
set       ProcessStepID "PMOS Halo/LDD"
#---------------------------------------------------------------------
implant Germanium dose= 2e14<cm-2> energy= 100<keV> tilt= 0 rotation= 0
implant Boron     dose= 5e14<cm-2> energy=   2<keV> tilt= 0 rotation= 0 \
  info= 2
implant Arsenic  dose= 6e13<cm-2> energy= 60<keV> tilt= 15<degree> rotation= 0 \
  mult.rot= 4  info= 2

SetPlxList { Boron_Implant Arsenic_Implant Damage Int_Implant}
WritePlx   n@node@_LDDimpl.plx   y= 0

#---------------------------------------------------------------------
set       ProcessStepID "SDextension RTA"
#---------------------------------------------------------------------
diffuse   time= 1.0e-12<min>   temperature= 600<C>

SetPlxList { BTotal BActive  AsTotal  AsActive ITotal VTotal }
WritePlx  n@node@_LDDrta_init.plx    y= 0

temp_ramp name= LDDrta time= 2<s> temperature= 600.0<C> ramprate= 150.0<K/s>
temp_ramp name= LDDrta time= 0.1<s> temperature= 900.0<C> 
temp_ramp name= LDDrta time= 4.0<s> temperature= 900.0<C> ramprate=-75.0<K/s>
diffuse   temp.ramp= LDDrta init= 1e-8<min>

WritePlx  n@node@_LDDrta.plx y=0

exit








