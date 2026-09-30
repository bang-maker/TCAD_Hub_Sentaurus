#set awidth 10
#if @Overlap@
#set width @<LJTE2+awidth+50>@
#else
#set width @<LJTE1+LJTE2+awidth+50>@
#endif

line x location= @epithick@     spacing= 0.5	tag= xtop
line x location= @<epithick+5>@ spacing= 1.0 tag= xbottom
line y location= 0       		tag= yleft
line y location= @width@    		tag= yright

region SiliconCarbide xlo= xtop xhi= xbottom ylo= yleft yhi= yright
init field= Nitrogen concentration= 1e19 !DelayFullD \
	wafer.orient= {0 0 1} notch.direction= {1 1 0} \
	miscut.tilt= @miscut@ miscut.toward= {1 1 0}

AdvancedCalibration 4H-SiC

refinebox clear
refinebox name= Global SiliconCarbide xrefine= 10.0 yrefine= 10.0
refinebox name= Intf interface.mat.pairs= {SiliconCarbide Gas} min.normal.size= 0.020 normal.growth.ratio= 2.0
refinebox name= Box1 min= {0 0} max= {1.5 @width@} xrefine= 0.050 yrefine= 1.0
refinebox name= Box2 min= {0 @awidth@} max= {0.5 @<awidth+LJTE1>@} xrefine= 0.050 yrefine= 1.0
refinebox name= Box3 min= {0 @<awidth-0.5>@} max= {0.5 @awidth@} xrefine= 0.1 yrefine= 0.1
refinebox name= Box4 min= {0 @<awidth+LJTE1-0.5>@} max= {0.5 @<awidth+LJTE1+0.5>@} xrefine= 0.1 yrefine= 0.1
refinebox name= Box5 min= {0 @<awidth+LJTE1+LJTE2>@} max= {0.5 @<awidth+LJTE1+LJTE2+0.5>@} xrefine= 0.1 yrefine= 0.1

#-- Epilayer 
deposit SiliconCarbide anisotropic thickness= @epithick@ species= Nitrogen \
	concentration= 9e15


#split @implant@

math numThreads= 4

mask name= JTE1 left= @awidth@ right= @<awidth+LJTE1>@
photo mask= JTE1 thickness= 3

implant Aluminum dose= 8e12 energy= 50 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 4e13 energy= 120 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 5e13 energy= 320 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
	
strip Photoresist

struct tdr= n@node@_JTE1

#if @Overlap@
mask name= JTE2 left= @awidth@ right= @<awidth+LJTE2>@
#else
mask name= JTE2 left= @<awidth+LJTE1>@ right= @<awidth+LJTE1+LJTE2>@
#endif
photo mask= JTE2 thickness= 3

implant Aluminum dose= 1e12 energy= 50 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 3e12 energy= 150 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 4e12 energy= 400 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 5e12 energy= 900 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1

strip Photoresist

struct tdr= n@node@_JTE2

mask name= ANODE left= 0 right= @awidth@
photo mask= ANODE thickness= 3

implant Aluminum dose= 4e13 energy= 20 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 2e14 energy= 80 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
implant Aluminum dose= 2e14 energy= 160 tilt= 7 rotation= 0 \
	sentaurus.mc particles= @particles@ info= 1
	
strip Photoresist


#split @anneal@

# Activation
diffuse time= 30 temperature= 1700

# Passivation oxide
diffuse time= 120 temperature= 1200 H2O

#split @contact@

deposit oxide anisotropic thickness= 0.4

mask name= ANODE left= 0 right= @awidth@
photo mask= ANODE thickness= 1
etch Oxide anisotropic thickness= 0.6
strip Photoresist
deposit Aluminum type= fill coord= 0


#-- Meshing for device simulation 

set sx @<epithick+5>@
set sy @width@ 

set stepx [expr min(2, $sx/pow(2, 4))]
set stepy [expr min(6, $sy/pow(2, 4))]


refinebox clear

grid set.Delaunay.type= boxmethod

refinebox SiliconCarbide xrefine=$stepx yrefine=$stepy

#-- refinement boxes
#if @Overlap@
refinebox name= corner_box SiliconCarbide min= {-1 @<awidth+LJTE2-5.>@} \
          max= {@epithick@ @<awidth+LJTE2+10.>@} \
          xrefine= [expr $stepx/4] yrefine= [expr $stepy/4]
refinebox name= active_box SiliconCarbide min= {-1 0} \
          max= {$sx @<awidth+LJTE2+15.>@} yrefine=[ expr $stepy/2]
#else
refinebox name= corner_box SiliconCarbide min= {-1 @<awidth+LJTE1+LJTE2-25.>@} \
          max= {@epithick@ @<awidth+LJTE1+LJTE2+10.>@} \
          xrefine= [expr $stepx/4] yrefine= [expr $stepy/4]
refinebox name= active_box SiliconCarbide min= {-1 0} \
          max= {$sx @<awidth+LJTE1+LJTE2+15.>@} yrefine=[ expr $stepy/2]
#endif

refinebox name= doping SiliconCarbide Adaptive \
	refine.fields= {NetActive} max.asinhdiff= {NetActive= 1.0} \
	refine.min.edge= {0.015 0.1} refine.max.edge= {$stepx $stepy}
refinebox interface.mat.pairs= {SiliconCarbide Oxide} \
	min.normal.size= 0.001 normal.growth.ratio= 2
refinebox interface.mat.pairs= {SiliconCarbide Aluminum} \
	min.normal.size= 0.001 normal.growth.ratio= 2
grid remesh info= 2

contact name= anode point x= 0.01 y= 0.1 Aluminum replace
contact name= cathode bottom

#seth areafactor @[format %.1e @<1e8/width>@]@

struct tdr= n@node@ !Gas

