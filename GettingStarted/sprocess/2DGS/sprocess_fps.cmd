# 2D nMOSFET (0.18um technology)
# ------------------------------


# Declare initial grid (half structure)
# -------------------------------------

line x location= 0.0      spacing= 1.0<nm>  tag= SiTop        
line x location= 50.0<nm> spacing= 10.0<nm>                    
line x location= 0.5<um>  spacing= 50.0<nm>                      
line x location= 2.0<um>  spacing= 0.2<um>                       
line x location= 4.0<um>  spacing= 0.4<um>                       
line x location= 10.0<um> spacing= 2.0<um>  tag= SiBottom   

line y location= 0.0      spacing= 50.0<nm> tag= Mid         
line y location= 0.40<um> spacing=50.0<nm>  tag= Right       

# Silicon substrate definition
# ----------------------------

region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right

# Initialize the simulation
# -------------------------

init concentration= 1.0e+15<cm-3> field= Phosphorus

AdvancedCalibration 

# p-well, anti-punchthrough & Vt adjustment implants
# --------------------------------------------------

implant  Boron  dose= 2.0e13<cm-2>  energy= 200<keV> tilt= 0 rotation= 0  
implant  Boron  dose= 1.0e13<cm-2>  energy= 80<keV> tilt= 0 rotation= 0  
implant  Boron  dose= 2.0e12<cm-2>  energy= 25<keV> tilt= 0 rotation= 0  

# p-well: RTA of channel implants
# -------------------------------

diffuse temperature= 1050<C> time= 10.0<s>   

# Saving structure
# ----------------

struct tdr= n@node@_NMOS1  ; # p-Well

# Global Mesh settings for automatic meshing in newly generated layers
# --------------------------------------------------------------------

grid set.min.normal.size= 1<nm> set.normal.growth.ratio.2d= 1.5
mgoals accuracy= 1e-5

pdbSet Oxide Grid perp.add.dist 1e-7
pdbSet Grid NativeLayerThickness 1e-7

# Gate oxidation
# --------------

diffuse temperature= 850<C> time= 10.0<min> O2

select z=1
layers

struct tdr= n@node@_NMOS2 ; # GateOx

# Poly gate deposition
# --------------------

deposit material= {PolySilicon} type= anisotropic time= 1 rate= {0.18}

# Poly gate pattern/etch
# ----------------------

mask name= gate_mask left=-1 right= 90<nm>
etch material= {PolySilicon} type= anisotropic time= 1 rate= {0.2} \
  mask= gate_mask
etch material= {Oxide}       type= anisotropic time= 1 rate= {0.1}
struct tdr= n@node@_NMOS3 ; # PolyGate

# Poly reoxidation
# ----------------

diffuse temperature= 900<C> time= 10.0<min>  O2 
struct tdr= n@node@_NMOS4 ; # Poly Reox

# LDD implantation
# ----------------

refinebox Silicon min= {0.0 0.05} max= {0.1 0.12} xrefine= {0.01 0.01 0.01} \
                                                  yrefine= {0.01 0.01 0.01} add
grid remesh

implant Arsenic dose= 4e14<cm-2> energy= 10<keV> tilt= 0 rotation= 0  
diffuse temperature= 1050<C> time= 0.1<s> ; # Quick activation 
struct tdr= n@node@_NMOS5 ; # LDD Implant

# Halo implantation: Quad HALO implants
# -------------------------------------

implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 0            
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 90<degree>   
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 180<degree>  
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 270<degree>  

# RTA of LDD/HALO implants
# ------------------------

diffuse temperature= 1050<C> time= 5.0<s>
struct tdr= n@node@_NMOS6 ; # Halo RTA

# Nitride spacer
# --------------

deposit material= {Nitride} type= isotropic  time= 1 rate= {0.06}
etch    material= {Nitride} type= anisotropic time=1 rate= {0.084} \
				isotropic.overetch= 0.01
etch    material= {Oxide}   type= anisotropic time= 1 rate= {0.01} 
struct tdr= n@node@_NMOS7 ; # Spacer

# N+ implantation
# ---------------

refinebox Silicon min= {0.04 0.12} max= {0.18 0.4} xrefine= {0.01 0.01 0.01} \
                                                   yrefine= {0.05 0.05 0.05} add
grid remesh
implant Arsenic dose= 5e15<cm-2> energy= 40<keV> \
        tilt= 7<degree> rotation= -90<degree>  

# N+ implantation & final RTA
# ---------------------------

diffuse temperature= 1050<C> time= 10.0<s> 
struct tdr= n@node@_NMOS8 ; # S/D implants

# Contacts
# --------

deposit material= {Aluminum} type= isotropic time= 1 rate= {0.03}

mask name= contacts_mask left= 0.2<um> right= 1.0<um>
etch material= {Aluminum} type= anisotropic time= 1 rate= {0.25} \
     mask= contacts_mask
etch material= {Aluminum} type= isotropic   time= 1 rate= {0.02} \
     mask= contacts_mask

# Reflect
# -------

transform reflect left 
struct tdr= n@node@_NMOS ; # Final

# save final structure:
#  - 1D cross sections

SetPlxList   {BTotal NetActive}
WritePlx n@node@_NMOS_channel.plx  y=0.0 Silicon

SetPlxList   {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_ldd.plx y=0.1 Silicon

SetPlxList   {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_sd.plx y=0.39 Silicon

exit

