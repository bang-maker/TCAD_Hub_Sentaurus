#header

icwb filename= "@pwd@/BiCMOS_lyt.mac" scale=1e-3
icwb domain= @Domain@ 
icwb stretch name= "@stretch@" value= @stretchlength@

#endheader

grid set.min.normal.size= 0.01 set.normal.growth.ratio.2d= 1.618 set.min.edge= 5e-5
mgoals accuracy= 2e-5 
refinebox interface.materials= {Silicon Oxide PolySilicon}


#rem # Query utility: Returns the bounding box of the simulation
fset Ymin [icwb bbox left ]
fset Ymax [icwb bbox right]
fset Zmin [icwb bbox back ]
fset Zmax [icwb bbox front]
LogFile "icwb: Centered Bounding Box -> $Ymin $Ymax $Zmin $Zmax"


fset LXmin [icwb bbox xmin]
fset LXmax [icwb bbox xmax]
fset LYmin [icwb bbox ymin]
fset LYmax [icwb bbox ymax]
LogFile "icwb: Layout Bounding Box -> $LXmin $LXmax $LYmin $LYmax"


fset DIM [icwb dimension]

line x location= 0.0       spacing= 100.0 tag= top
line x location= 10.0       spacing= 100.0 tag= bot

set Ydim ""
set Zdim ""

if {$DIM == 2} {
  line y location= $Ymin   spacing= 100.0 tag= left
  line y location= $Ymax   spacing= 100.0 tag= right
  set Ydim "ylo=left yhi=right"
  set Zdim ""
}  

if {$DIM == 3} {
  line y location= $Ymin   spacing= 100.0 tag= left
  line y location= $Ymax   spacing= 100.0 tag= right
  line z location= $Zmin   spacing= 100.0 tag= front
  line z location= $Zmax   spacing= 100.0 tag= back
  set Ydim "ylo=left yhi=right"
  set Zdim "zlo=front zhi=back"
}

eval region Silicon xlo= top xhi= bot $Ydim $Zdim


init Silicon field= Boron concentration= 1e14 wafer.orient= 100

AdvancedCalibration

refinebox name= BG \
      min= " -5.0 $Ymin $Zmin" max= "10.0 $Ymax $Zmax" \
      def.max.dose.error= 1.0E8 \
      refine.min.edge= "0.15 0.15 0.15" \
      refine.max.edge= {0.75 0.75 0.75} \
      Adaptive add


#--- Burried Implants

icwb.create.mask layer.name= NWELL name= NWELL polarity= negative info=1
deposit Photoresist thickness= 5.0
etch Photoresist mask= NWELL thickness= 5.5 anisotropic
implant Antimony  dose= 2e14<cm-2> energy= 200<keV> tilt= 0 rotation= 0
strip Photoresist

icwb.create.mask layer.name= NWELL name= NOTNWELL  polarity= positive info=1
deposit Photoresist thickness= 5.0
etch Photoresist mask= NOTNWELL thickness= 7.0 anisotropic
implant Boron dose= 4e14<cm-2> energy= 50<keV>  tilt= 0 rotation= 0
strip Photoresist

#rem # Drive-in (emulated caping oxide growth)
deposit Oxide thickness= 0.05
diffuse time= 10<min> temperature= 1050 
strip Oxide




#----- Epi Layer and Well Implants

deposit Silicon thickness= 1.5 

icwb.create.mask layer.name= POLY name= POLY

refinebox name= UnderPoly mask= POLY  \
      extend= 0.1 extrusion.min=-1.51 extrusion.max=-1.35 \
      xrefine= 0.02 yrefine= 0.02 info= 1
refinebox name= SiOxPo mask= POLY  \
      extend= 0.1 extrusion.min=-1.51 extrusion.max=-1.35 \
      min.normal.size= 0.005 interface.mat.pairs= {Silicon Oxide Silicon PolySilicon} 


deposit Photoresist thickness= 8.0
etch Photoresist mask= NWELL thickness= 10.0 anisotropic
implant Arsenic dose= 1e13<cm-2> energy= 1200<keV> tilt= 0 rotation= 0
implant Arsenic dose= 1e13<cm-2> energy= 600<keV> tilt= 0 rotation= 0
implant Arsenic dose= 3e11<cm-2> energy= 20<keV> tilt= 0 rotation= 0
strip Photoresist

deposit Photoresist thickness= 8.0
etch Photoresist mask= NOTNWELL thickness= 10.0 anisotropic
implant Boron dose= 2e13<cm-2> energy= 180<keV> tilt= 0 rotation= 0
implant Boron dose= 2e13<cm-2> energy= 10<keV> tilt= 0 rotation= 0
strip Photoresist

# Drive-in (emulated screening oxide growth)
deposit Oxide thickness= 0.05
diffuse time= 10<min> temperature= 1050 
strip Oxide



#split STI

#---- Channelstop and STI

icwb.create.mask layer.name= "NPDIFF PPDIFF NPLUG PBASE" name= STI info= 1 
deposit Photoresist thickness= 1.0
etch Photoresist mask= STI thickness= 3.0 anisotropic
implant Boron dose= 1e13<cm-2> energy= 40<keV> tilt= 0 rotation= 0


etch Silicon thickness= 0.85<um> type= trapezoidal angle= 88.0

strip Photoresist

deposit Oxide type= fill coord= -1.6 
etch Oxide type= cmp etchstop= Silicon etchstop.overetch= 0


#---- BJT sub-collector implant and GOX


icwb.create.mask layer.name= NPLUG polarity= negative

deposit Photoresist thickness= 1.0
etch Photoresist mask= NPLUG thickness= 3.0 anisotropic
implant Phosphorus dose= 5e14<cm-2> energy= 300<keV> tilt= 0 rotation= 0
strip Photoresist

deposit Oxide thickness= 0.005 

diffuse time= 1<s> temperature= 900 


#split BASE
#---- Opening BJT base and BJT base implant




refinebox name= TopArea \
      min= "-1.5 $Ymin $Zmin" max= "-1.1 $Ymax $Zmax" \
      def.max.dose.error= 1.0E8 \
      refine.min.edge= {0.05 0.05 0.05} \
      refine.max.edge= {0.75 0.75 0.75} \
      Adaptive add

icwb.create.mask layer.name= PBASE name= PBASE polarity= negative

refinebox name= Base mask= PBASE  \
      extend= 0.0 extrusion.min=-1.4 extrusion.max=-1.2 \
      xrefine= 0.02 yrefine= 0.05 info= 1



deposit Photoresist thickness= 1.0
etch Photoresist mask= PBASE thickness= 3.0 anisotropic
implant Boron dose= 1e13<cm-2> energy= 20<keV> tilt= 0 rotation= 0
strip Photoresist

etch Oxide mask= PBASE thickness= 0.007 anisotropic

diffuse time= 20<s> temperature= 900 


#split POLY
#---- Poly Patterning
icwb.create.mask layer.name= POLY

#if [string match @Domain@ "NMOS"]
doping  name= PolyDop field= Arsenic depths= "0 0.5" values= "1e20 1e20"
#endif
#if [string match @Domain@ "PMOS"]
doping  name= PolyDop field= Boron depths= "0 0.5" values= "1e20 1e20"
#endif

deposit PolySilicon type= fill  doping= PolyDop coord= -2.0 

etch PolySilicon mask= POLY thickness= 0.53<um> anisotropic
diffuse time= 3<min> temperature= 1050 


#split SD
#----NMOS Extenstion, Spacer formation and NMOS SD

icwb.create.mask layer.name= "NPDIFF" name= NMOSSD polarity= negative
deposit Photoresist thickness= 0.4
etch Photoresist mask= NMOSSD thickness= 2.0 anisotropic
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 0
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 90
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 180
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 270
strip Photoresist

icwb.create.mask layer.name= "PPDIFF" name= PMOSSD polarity= negative
deposit Photoresist thickness= 0.4
etch Photoresist mask= PMOSSD thickness= 2.0 anisotropic
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 0
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 90
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 180
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 270
strip Photoresist

diffuse time= 1<s> temperature= 900 


#---- SD

deposit Nitride thickness= 0.10 isotropic 
etch    Nitride thickness= 0.13<um> anisotropic
deposit Photoresist thickness= 0.4
etch Photoresist mask= NMOSSD thickness= 2.0 anisotropic
implant Arsenic dose= 2e14<cm-2> energy=50<keV> tilt= 0 rotation= 0
strip Photoresist


deposit Photoresist thickness= 0.4
etch Photoresist mask= PMOSSD thickness= 2.0 anisotropic
implant Boron dose= 2e14<cm-2> energy= 10<keV> tilt= 0 rotation= 0
strip Photoresist

diffuse time=1<min> temperature= 1000 


#split CONTACT


deposit Oxide type= fill coord= -2.3 
icwb.create.mask layer.name= CONT polarity= negative
etch Oxide mask= CONT thickness= 1.8<um> anisotropic 
deposit Aluminum  type= fill coord=-2.5


#---- Metallization

icwb.create.mask layer.name= METAL
deposit Aluminum  thickness= 0.5
etch Aluminum mask= METAL thickness= 1.0<um> anisotropic
deposit Oxide type= fill coord= -4.0






#split @REMESH@

refinebox clear
refinebox interface.materials = "Silicon Oxide"

# specify meshing parameters
grid set.min.normal.size= 0.05 set.normal.growth.ratio.2d= 1.5 set.Delaunay.type= boxmethod

line clear

refinebox name= SiliconInterface \
  min.normal.size= 0.001 \
  interface.materials = "Silicon" \
  min = "-5.0 -100.0" max = "100.0 100.0"
  
refinebox name= BG \
    refine.min.edge= "0.0025 0.0025" refine.max.edge= "0.5 0.5" \
    min= "-5.0 -100.0" max= "100.0 100.0" \
    refine.fields= { NetActive } def.max.asinhdiff= 1.0 \
    def.max.dose.error= 1.0E10 \
    Silicon

##abs.error= { NetActive=1E10 } rel.error= { NetActive=1.5 }
grid remesh 

set polyox [interface oxide /polysilicon  y=0.7] 
etch type= cmp coord= $polyox 

set yinterface [interface Nitride /polysilicon x= -1.75]
set y1 [expr $yinterface -0.4]
set y2 [expr $yinterface +0.7+@stretchlength@] 

struct tdr=n@node@_BeforeCut

transform cut min= {-2.5 $y1} max= {2.0 $y2}
grid remesh

#---- Contact assignements

#if [ string match @Domain@ "NMOS" ]
  icwb.contact.mask layer.name= ndrain  name= "drain"  point Aluminum x= -1.75
  icwb.contact.mask layer.name= nsource name= "source" point Aluminum x= -1.75
  icwb.contact.mask layer.name= ngate   name= "gate"   box PolySilicon adjacent.material= Gas  xlo= -2.05 xhi= -1.95
#elseif [string match @Domain@ "PMOS" ]
  icwb.contact.mask layer.name= pdrain  name= "drain"   point Aluminum  x= -1.75
  icwb.contact.mask layer.name= psource name= "source"  point Aluminum x= -1.75
  icwb.contact.mask layer.name= pgate   name= "gate"    box PolySilicon adjacent.material= Gas  xlo= -2.05 xhi= -1.95
#endif

contact name= substrate bottom

LogFile Nnodes "= [grid quality nodes]"            

struct tdr=n@node@

