
pdbSet Silicon Dopant DiffModel Constant

line x location= 0.0<um>   tag= SubTop      spacing= 20.0<nm>
line x location= 2.0<um>   tag= SubBottom   spacing= 20.0<nm>

region Silicon xlo= SubTop xhi= SubBottom
init concentration= 1e+10<cm-3> field= Boron

implant species= Boron Silicon gaussian

implant Boron dose= 1e14<cm-2> energy= 400.0<keV> 

SetPlxList {Boron_Implant}
WritePlx n@node@_AsImplant.plx
struct tdr= n@node@_AsImplant

diffuse temperature= 1000<C> time= 1<hr> 
SetPlxList {BTotal}
WritePlx n@node@_D1.plx

line clear

init tdr= n@node@_AsImplant
pdbSet Silicon Boron Dstar "\[expr 4.0*[pdbDelayDouble Silicon Boron Dstar]\]"
diffuse temperature= 1000<C> time= 1<hr>

WritePlx n@node@_D2.plx

exit


