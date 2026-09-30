#header
set layout "./14ff_aoi221.mac"
set domain @Type@
set cell a
icwb filename= "$layout" cell="$cell" scale= 1e-3
icwb domain= $domain
icwb stretch name= lgate value=@<(L-0.028)/2>@

#endheader

AdvancedCalibration

source material.tcl

math numThreads=4
refinebox clear
refinebox name=channel materials= {Silicon SiGe} xrefine=0.002 max= "@<H+0.005>@ 1 1"
refinebox name=active materials= {Silicon SiGe} xrefine=0.01 yrefine=0.01 zrefine=0.01
refinebox interface.materials= {Silicon SiGe} name=interface min.normal.size=0.001

icwb.create.mask  \
  layer.name= "3:201"\
  shift= "0 0" \
  polarity= "negative" \
  name= "gate_refinment_mask"

set gm_bbox [mask  \
  name= "gate_refinment_mask" \
  bbox ]
 
  
set mins [lindex $gm_bbox 0]
set maxs [lindex $gm_bbox 1]
set efffw @<W+0.002-H*tan((90-a_fin)*3.14159265359/180)>@
#if "@Type@"=="nMOS"
 

set ygmax [lindex $mins 0]
set ygmax [expr ${ygmax}*1.0e4]
set ygmin [expr ${ygmax}-$efffw]
#else

 
set ygmin [lindex $maxs 0]
set ygmin [expr ${ygmin}*1.0e4]
set ygmax [expr ${ygmin}+$efffw]

#endif


set zgmin  0.019
# set zgmax [expr $zgmin +@L@/2 ] 


refinebox name=gateedge \
          min= "0        $ygmin          $zgmin-0.001" \
          max= "@H@      $ygmax          $zgmin+0.005" \
          zrefine= 0.0005


pdbSet InfoDefault 1 
mgoals analytic.thickness=0.0001 accuracy=1e-6

### Wafer Start ###

set Ymin [icwb bbox left ]
set Ymin [expr $Ymin-0.01]
set Ymax [icwb bbox right]
set Ymax [expr $Ymax+0.01]
set Zmin [icwb bbox back ]
set Zmax [icwb bbox front]
line x location= 0.0 tag= top
line x location= 0.29999999999999999 tag= bottom
line y location= $Ymin tag= left
line y location= $Ymax tag= right
line z location= $Zmin tag= back
line z location= $Zmax tag= front
region Silicon substrate xlo= top xhi= bottom ylo= left yhi= right zlo= back zhi= front 

# init !DelayFullD 




#if "@sOri@" == "100" && "@cDir@" == "100"
init  wafer.orient = { 0 0 1 }  flat.orient = { 1 0 0 } !DelayFullD 
#elif "@sOri@" == "100" && "@cDir@" == "110"
init  wafer.orient = { 0 0 1 }  flat.orient = { 1 1 0 } !DelayFullD 
#elif "@sOri@" == "110" && "@cDir@" == "100"
init  wafer.orient = { 1 1 0 }  flat.orient = { 0 0 1 } !DelayFullD 
#elif "@sOri@" == "110" && "@cDir@" == "110"
init wafer.orient = { 1 -1 0 }  flat.orient = { 1 1 0 } !DelayFullD 
#endif



  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_Wafer_Start_substrate_control_save_3D.tdr

# #split Well_Formation

### Well_Formation ###

etch  \
  type= "cmp" \
  coord= "@<H>@" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_Well_Formation_etch_cmp_top_silicon_50nm_control_save_3D.tdr

deposit  \
  material= "Oxide" \
  type= "fill" \
  coord= "@<H-0.01>@" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_2_frontend_1_frontend_Well_Formation_depo_fill_screen_oxide_for_implant_10nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 1:0 \
  shift= "0 0" \
  polarity= "positive" \
  name= "frontend_1_frontend_Well_Formation_nwell_mask_m0"

mask  \
  name= "frontend_1_frontend_Well_Formation_nwell_mask_m1" \
  bool= "bias(0, frontend_1_frontend_Well_Formation_nwell_mask_m0)"

photo  \
  thickness= "0.5" \
  mask= "frontend_1_frontend_Well_Formation_nwell_mask_m1"

  # struct \ 
    # # tdr.bnd=n@node@_3_frontend_1_frontend_Well_Formation_nwell_mask_control_save_3D.tdr

grid  \
  remesh 

implant  \
  Phosphorus  \
  dose= "1e14" \
  energy= "40"

  # struct \ 
    # # tdr.bnd=n@node@_4_frontend_1_frontend_Well_Formation_implant_ellipsoidal_nwell_control_save_3D.tdr

strip  \
   "Photoresist"

  # struct \ 
    # # tdr.bnd=n@node@_5_frontend_1_frontend_Well_Formation_etch_strip_resist_control_save_3D.tdr

diffuse  \
  temp= "900" \
  time= "1<s>"

  # struct \ 
    # # tdr.bnd=n@node@_6_frontend_1_frontend_Well_Formation_diffuse_nwell_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 1:0 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_Well_Formation_pwell_mask_m0"

mask  \
  name= "frontend_1_frontend_Well_Formation_pwell_mask_m1" \
  bool= "bias(0, frontend_1_frontend_Well_Formation_pwell_mask_m0)"

photo  \
  thickness= "0.5" \
  mask= "frontend_1_frontend_Well_Formation_pwell_mask_m1"

  # struct \ 
    # # tdr.bnd=n@node@_7_frontend_1_frontend_Well_Formation_pwell_mask_control_save_3D.tdr

grid  \
  remesh 

implant  \
  Boron  \
  dose= "1e14" \
  energy= "10"

  # struct \ 
    # # tdr.bnd=n@node@_8_frontend_1_frontend_Well_Formation_implant_ellipsoidal_pwell_control_save_3D.tdr

strip  \
   "Photoresist"

  # struct \ 
    # # tdr.bnd=n@node@_9_frontend_1_frontend_Well_Formation_etch_strip_resist_01_control_save_3D.tdr

diffuse  \
  temp= "900" \
  time= "1<s>"

  # struct \ 
    # # tdr.bnd=n@node@_10_frontend_1_frontend_Well_Formation_diffuse_pwell_control_save_3D.tdr

strip  \
   "Oxide"

  # struct \ 
    # # tdr.bnd=n@node@_11_frontend_1_frontend_Well_Formation_etch_strip_oxide_control_save_3D.tdr

deposit  \
  material= "Silicon" \
  coord= "0" \
  type= "fill" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_12_frontend_1_frontend_Well_Formation_depo_fill_silicon_channel_control_save_3D.tdr

# #split Fin_Hardmask

### Fin_Hardmask ###

deposit  \
  material= "Oxide" \
  rate= "1" \
  time= "0.0050000000000000001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_Fin_Hardmask_depo_iso_oxide_5nm_control_save_3D.tdr

deposit  \
  material= "Nitride" \
  rate= "1" \
  time= "0.035000000000000003" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_2_frontend_1_frontend_Fin_Hardmask_depo_iso_nitride_35nm_control_save_3D.tdr

# #split Fin_SADP_Spacer

### Fin_SADP_Spacer ###

deposit  \
  material= "PolySilicon" \
  rate= "1" \
  time= "0.080000000000000002" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_Fin_SADP_Spacer_depo_iso_poly_80nm_control_save_3D.tdr

deposit  \
  material= "Oxide3" \
  coord= "-0.27" \
  type= "fill" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_2_frontend_1_frontend_Fin_SADP_Spacer_depo_fill_oxide3_150_control_save_3D.tdr

deposit  \
  material= "NitrideARC" \
  rate= "1" \
  time= "0.01" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_3_frontend_1_frontend_Fin_SADP_Spacer_depo_iso_nitrideARC_10nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 3:201 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_Fin_SADP_Spacer_fin_mandrel_mask_m0"

mask  \
  name= "frontend_1_frontend_Fin_SADP_Spacer_fin_mandrel_mask_m1" \
  bool= "bias(0, frontend_1_frontend_Fin_SADP_Spacer_fin_mandrel_mask_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_Fin_SADP_Spacer_fin_mandrel_mask_m1"

  # struct \ 
    # # tdr.bnd=n@node@_4_frontend_1_frontend_Fin_SADP_Spacer_fin_mandrel_mask_control_save_3D.tdr

etch  \
  time= "0.010999999999999999" \
  type= "anisotropic" \
  material= "NitrideARC" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_5_frontend_1_frontend_Fin_SADP_Spacer_etch_ellipso_nitrideARC_control_save_3D.tdr

etch  \
  time= "0.151" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_6_frontend_1_frontend_Fin_SADP_Spacer_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.081000000000000003" \
  type= "anisotropic" \
  material= "PolySilicon" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_7_frontend_1_frontend_Fin_SADP_Spacer_etch_ellipso_poly_control_save_3D.tdr

strip  \
   "Photoresist"

  # struct \ 
    # # tdr.bnd=n@node@_8_frontend_1_frontend_Fin_SADP_Spacer_etch_strip_resist_control_save_3D.tdr

strip  \
   "NitrideARC"

  # struct \ 
    # # tdr.bnd=n@node@_9_frontend_1_frontend_Fin_SADP_Spacer_etch_strip_nitrideARC_control_save_3D.tdr

strip  \
   "Oxide3"

  # struct \ 
    # # tdr.bnd=n@node@_10_frontend_1_frontend_Fin_SADP_Spacer_etch_strip_oxide3_control_save_3D.tdr

#_meas_CD_fromtop 

  # struct \ 
    # # tdr.bnd=n@node@_11_frontend_1_frontend_Fin_SADP_Spacer_meas_CD_fromtop_mandrel_poly_control_save_3D.tdr

deposit  \
  material= "OxideCVD" \
  rate= "1" \
  time= "@<W+0.002-H*tan((90-a_fin)*3.14159265359/180)>@" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_12_frontend_1_frontend_Fin_SADP_Spacer_depo_iso_oxideCVD_spacer_12nm_control_save_3D.tdr

etch  \
  time= "0.028000000000000001" \
  material= "OxideCVD" \
  type= "anisotropic" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_13_frontend_1_frontend_Fin_SADP_Spacer_etch_ansio_spacer_control_save_3D.tdr

strip  \
   "PolySilicon"

  # struct \ 
    # tdr.bnd=n@node@_14_frontend_1_frontend_Fin_SADP_Spacer_etch_strip_poly_control_save_3D.tdr

#split @Fin_HM_Patterning@

### Fin_HM_Patterning ###

etch  \
  time= "0.041000000000000002" \
  material= "Nitride Oxide" \
  type= "anisotropic" \
  rate= "1 1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_Fin_HM_Patterning_etch_aniso_ox_nitride_HM_control_save_3D.tdr

strip  \
   "OxideCVD"

# struct \ 
     # tdr.bnd=n@node@_2_frontend_1_frontend_Fin_HM_Patterning_etch_strip_oxideCVD_spacer_control_save_3D.tdr

deposit  \
  material= "Oxide3" \
  coord= "-0.15" \
  type= "fill" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_3_frontend_1_frontend_Fin_HM_Patterning_depo_fill_ox3_150_control_save_3D.tdr

deposit  \
  material= "NitrideARC" \
  rate= "1" \
  time= "0.01" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_4_frontend_1_frontend_Fin_HM_Patterning_depo_iso_nitrideARC_10nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 3:0 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_Fin_HM_Patterning_diffusion_mask_m0"

mask  \
  name= "frontend_1_frontend_Fin_HM_Patterning_diffusion_mask_m1" \
  bool= "bias(0.005, frontend_1_frontend_Fin_HM_Patterning_diffusion_mask_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_Fin_HM_Patterning_diffusion_mask_m1"

# struct \ 
     # tdr.bnd=n@node@_5_frontend_1_frontend_Fin_HM_Patterning_diffusion_mask_control_save_3D.tdr

etch  \
  time= "0.010999999999999999" \
  type= "anisotropic" \
  material= "NitrideARC" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_6_frontend_1_frontend_Fin_HM_Patterning_etch_ellipso_nitrideARC_control_save_3D.tdr

etch  \
  time= "0.151" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_7_frontend_1_frontend_Fin_HM_Patterning_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.041000000000000002" \
  material= "Nitride Oxide" \
  type= "anisotropic" \
  rate= "1 1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_8_frontend_1_frontend_Fin_HM_Patterning_etch_aniso_ox_nitride_HM_01_control_save_3D.tdr

strip  \
   "Photoresist"

 # struct \ 
     # tdr.bnd=n@node@_9_frontend_1_frontend_Fin_HM_Patterning_etch_strip_resist_control_save_3D.tdr

strip  \
   "NitrideARC"

 # struct \ 
     # tdr.bnd=n@node@_10_frontend_1_frontend_Fin_HM_Patterning_etch_strip_nitrideARC_control_save_3D.tdr

strip  \
   "Oxide3"

 # struct \ 
     # tdr.bnd=n@node@_11_frontend_1_frontend_Fin_HM_Patterning_etch_strip_oxide3_control_save_3D.tdr

# #split Fin_Formation

### Fin_Formation ###

etch  \
  time= "0.12" \
  angle= "@a_fin@" \
  material= "Silicon" \
  type= "trapezoidal" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_Fin_Formation_etch_aniso_Si_40nm_control_save_3D.tdr

#_skip 

# struct \ 
     # tdr.bnd=n@node@_2_frontend_1_frontend_Fin_Formation_etch_microloading_Si_70nm_control_save_3D.tdr

#_meas_CD 

 # struct \ 
     # tdr.bnd=n@node@_3_frontend_1_frontend_Fin_Formation_meas_CD_fin_spacing1_control_save_3D.tdr

#_meas_CD 

 # struct \ 
     # tdr.bnd=n@node@_4_frontend_1_frontend_Fin_Formation_meas_CD_fin_spacing2_control_save_3D.tdr

deposit  \
  material= "Oxide2" \
  rate= "1" \
  time= "0.25" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_5_frontend_1_frontend_Fin_Formation_depo_iso_oxide2_fill_control_save_3D.tdr

etch  \
  material= "Oxide2" \
  type= "cmp" \
  offset= "0" \
  etchstop= "Nitride" \
  !repair  \
  suppress.remesh 

 # struct \ 
      # tdr.bnd=n@node@_6_frontend_1_frontend_Fin_Formation_etch_cmp_oxide2_planarization_control_save_3D.tdr

etch  \
  material= "Oxide2" \
  time= "@<H+0.035>@" \
  type= "anisotropic" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_7_frontend_1_frontend_Fin_Formation_etch_microloading_oxide2_etchback_control_save_3D.tdr

etch  \
  time= "0.0050000000000000001" \
  type= "isotropic" \
  material= "Oxide2" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_8_frontend_1_frontend_Fin_Formation_etch_iso_oxide2_sidewall_clean_control_save_3D.tdr

strip  \
   "Nitride"

# struct \ 
     # tdr.bnd=n@node@_9_frontend_1_frontend_Fin_Formation_etch_strip_nitride_HM_control_save_3D.tdr

strip  \
   "Oxide"

 # struct \ 
     # tdr.bnd=n@node@_10_frontend_1_frontend_Fin_Formation_etch_strip_oxide_HM_control_save_3D.tdr

etch  \
  time= "0.002" \
  type= "isotropic" \
  material= "Silicon" \
  rate= "1" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_11_frontend_1_frontend_Fin_Formation_etch_iso_Si_trim_2nm_oxidation_control_save_3D.tdr

deposit  \
  material= "Silicon" \
  rate= "1" \
  selective.materials= "Silicon" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_12_frontend_1_frontend_Fin_Formation_depo_iso_Si_regrow_0nm_rounding_control_save_3D.tdr

#_meas_CD 

 # struct \ 
     # tdr.bnd=n@node@_13_frontend_1_frontend_Fin_Formation_meas_CD_fin_mid_width_control_save_3D.tdr

# #split Poly_Patterning

### Poly_Patterning ###

deposit  \
  material= "Oxide" \
  rate= "1" \
  time= "0.0025000000000000001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_Poly_Patterning_depo_iso_oxide_2.5nm_control_save_3D.tdr

deposit  \
  material= "PolySilicon" \
  rate= "1" \
  time= "0.25" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_2_frontend_1_frontend_Poly_Patterning_depo_iso_poly_250nm_control_save_3D.tdr

etch  \
  material= "PolySilicon" \
  type= "cmp" \
  coord= "-0.053603" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_3_frontend_1_frontend_Poly_Patterning_etch_cmp_poly_55nm_control_save_3D.tdr

deposit  \
  material= "Oxide" \
  rate= "1" \
  time= "0.0050000000000000001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_4_frontend_1_frontend_Poly_Patterning_depo_iso_oxide_5nm_control_save_3D.tdr

deposit  \
  material= "Nitride" \
  rate= "1" \
  time= "0.12" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

# struct \ 
     # tdr.bnd=n@node@_5_frontend_1_frontend_Poly_Patterning_depo_iso_nitride_HM_120nm_control_save_3D.tdr

deposit  \
  material= "Oxide3" \
  coord= "-0.32806" \
  type= "fill" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_6_frontend_1_frontend_Poly_Patterning_depo_fill_oxide3_150_control_save_3D.tdr

deposit  \
  material= "NitrideARC" \
  rate= "1" \
  time= "0.01" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_7_frontend_1_frontend_Poly_Patterning_depo_iso_nitrideARC_10nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 5:0 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_Poly_Patterning_poly_gate_mask_m0"

mask  \
  name= "frontend_1_frontend_Poly_Patterning_poly_gate_mask_m1" \
  bool= "bias(-0.01, frontend_1_frontend_Poly_Patterning_poly_gate_mask_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_Poly_Patterning_poly_gate_mask_m1"

 # struct \ 
     # tdr.bnd=n@node@_8_frontend_1_frontend_Poly_Patterning_poly_gate_mask_control_save_3D.tdr

#_meas_CD_fromtop 

# struct \ 
    # tdr.bnd=n@node@_9_frontend_1_frontend_Poly_Patterning_meas_CD_fromtop_poly_resist_control_save_3D.tdr

etch  \
  time= "0.010999999999999999" \
  type= "anisotropic" \
  material= "NitrideARC" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_10_frontend_1_frontend_Poly_Patterning_etch_ellipso_nitrideARC_control_save_3D.tdr

etch  \
  time= "0.151" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_11_frontend_1_frontend_Poly_Patterning_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.125" \
  material= "Nitride Oxide" \
  type= "anisotropic" \
  rate= "1 1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_12_frontend_1_frontend_Poly_Patterning_etch_aniso_ox_nitride_HM_control_save_3D.tdr

strip  \
   "Photoresist"

# struct \ 
    # tdr.bnd=n@node@_13_frontend_1_frontend_Poly_Patterning_etch_strip_resist_control_save_3D.tdr

strip  \
   "NitrideARC"

# struct \ 
    # tdr.bnd=n@node@_14_frontend_1_frontend_Poly_Patterning_etch_strip_nitrideARC_control_save_3D.tdr

strip  \
   "Oxide3"

# struct \ 
    # tdr.bnd=n@node@_15_frontend_1_frontend_Poly_Patterning_etch_strip_oxide3_control_save_3D.tdr

# #split Poly_Cut

### Poly_Cut ###

deposit  \
  material= "Oxide3" \
  coord= "-0.32806" \
  type= "fill" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_1_frontend_1_frontend_Poly_Cut_depo_fill_oxide3_150nm_control_save_3D.tdr

deposit  \
  material= "NitrideARC" \
  rate= "1" \
  time= "0.01" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_2_frontend_1_frontend_Poly_Cut_depo_iso_nitrideARC_10nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 5:11 \
  shift= "0 0" \
  polarity= "positive" \
  name= "frontend_1_frontend_Poly_Cut_poly_cut_mask_neg_m0"

mask  \
  name= "frontend_1_frontend_Poly_Cut_poly_cut_mask_neg_m1" \
  bool= "bias(0, frontend_1_frontend_Poly_Cut_poly_cut_mask_neg_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_Poly_Cut_poly_cut_mask_neg_m1"

# struct \ 
    # tdr.bnd=n@node@_3_frontend_1_frontend_Poly_Cut_poly_cut_mask_neg_control_save_3D.tdr

etch  \
  time= "0.010999999999999999" \
  type= "anisotropic" \
  material= "NitrideARC" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_4_frontend_1_frontend_Poly_Cut_etch_ellipso_nitrideARC_control_save_3D.tdr

etch  \
  time= "0.151" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_5_frontend_1_frontend_Poly_Cut_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.125" \
  material= "Nitride Oxide" \
  type= "anisotropic" \
  rate= "1 1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_6_frontend_1_frontend_Poly_Cut_etch_aniso_ox_nitride_HM_control_save_3D.tdr

strip  \
   "Photoresist"

# struct \ 
    # tdr.bnd=n@node@_7_frontend_1_frontend_Poly_Cut_etch_strip_resist_control_save_3D.tdr

strip  \
   "NitrideARC"

# struct \ 
    # tdr.bnd=n@node@_8_frontend_1_frontend_Poly_Cut_etch_strip_nitrideARC_control_save_3D.tdr

strip  \
   "Oxide3"

# struct \ 
    # tdr.bnd=n@node@_9_frontend_1_frontend_Poly_Cut_etch_strip_oxide3_control_save_3D.tdr

# #split Poly_Final

### Poly_Final ###

etch  \
  time= "0.10000000000000001" \
  type= "anisotropic" \
  material= "Oxide" \
  rate= "0.02" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_1_frontend_1_frontend_Poly_Final_etch_ellipso_poly_oxide_01_control_save_3D.tdr

etch  \
  time= "0.25" \
  type= "anisotropic" \
  material= "PolySilicon" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_2_frontend_1_frontend_Poly_Final_etch_ellipso_poly_oxide_02_control_save_3D.tdr

etch  \
  time= "0.25" \
  type= "anisotropic" \
  material= "Oxide" \
  rate= "0.02" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_3_frontend_1_frontend_Poly_Final_etch_ellipso_poly_oxide_03_control_save_3D.tdr

#_skip 

# struct \ 
    # tdr.bnd=n@node@_4_frontend_1_frontend_Poly_Final_etch_aniso_rm_poly_slivers_workaround_control_save_3D.tdr

#_meas_CD 

# struct \ 
    # tdr.bnd=n@node@_5_frontend_1_frontend_Poly_Final_meas_CD_poly_gate_fintop_control_save_3D.tdr

# #split Spacer_Dep

### Spacer_Dep ###

deposit  \
  material= "Nitride2" \
  rate= "1" \
  time= "@t_spacer@" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_1_frontend_1_frontend_Spacer_Dep_depo_iso_spacer_nitride2_15nm_control_save_3D.tdr

# #split PMOS_SD_Epi

### PMOS_SD_Epi ###

deposit  \
  material= "Oxide3" \
  coord= "-0.18806" \
  type= "fill" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_1_frontend_1_frontend_PMOS_SD_Epi_depo_fill_oxide3_190_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 1:0 \
  shift= "0 0" \
  polarity= "positive" \
  name= "frontend_1_frontend_PMOS_SD_Epi_well_mask_neg_m0"

mask  \
  name= "frontend_1_frontend_PMOS_SD_Epi_well_mask_neg_m1" \
  bool= "bias(0, frontend_1_frontend_PMOS_SD_Epi_well_mask_neg_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_PMOS_SD_Epi_well_mask_neg_m1"

# struct \ 
    # tdr.bnd=n@node@_2_frontend_1_frontend_PMOS_SD_Epi_well_mask_neg_control_save_3D.tdr

etch  \
  time= "0.25" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_3_frontend_1_frontend_PMOS_SD_Epi_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.063" \
  type= "anisotropic" \
  material= "Nitride2" \
  rate= "1" \
  !repair  \
  suppress.remesh 

# struct \ 
    # tdr.bnd=n@node@_4_frontend_1_frontend_PMOS_SD_Epi_etch_ellipso_spacer_nitride2_control_save_3D.tdr

#_skip 

# struct \ 
    # tdr.bnd=n@node@_5_frontend_1_frontend_PMOS_SD_Epi_etch_iso_nitride2_remove_sliver_control_save_3D.tdr

strip  \
   "Photoresist"

 # struct \ 
     # tdr.bnd=n@node@_6_frontend_1_frontend_PMOS_SD_Epi_etch_strip_resist_control_save_3D.tdr

strip  \
   "Oxide3"

 # struct \ 
     # tdr.bnd=n@node@_7_frontend_1_frontend_PMOS_SD_Epi_etch_strip_oxide3_control_save_3D.tdr

etch  \
  time= "1" \
  material= "Silicon" \
  rate= "0.040000000000000001" \
  type= "directional" \
  direction= "0.01 1 0" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_8_frontend_1_frontend_PMOS_SD_Epi_etch_directional_silicon_control_save_3D.tdr

etch  \
  material= "Silicon" \
  rate= "1" \
  type= "directional" \
  direction= "1 0 0" \
  time= "@<H-t_spacer-0.002>@" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_9_frontend_1_frontend_PMOS_SD_Epi_etch_aniso_silicon_control_save_3D.tdr

etch  \
  type= "isotropic" \
  material= "Silicon" \
  rate= "1" \
  type= "isotropic" \
  time= "@<t_spacer+0.002>@" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_10_frontend_1_frontend_PMOS_SD_Epi_etch_iso_trim_bottom_Si_control_save_3D.tdr

mgoals  \
  dx= "0.00050000000000000001" \
  dy= "0.00050000000000000001" \
  dz= "0.00050000000000000001"

deposit  \
  material= "Silicon" \
  selective.materials= "Silicon" \
  time= "0.059999999999999998" \
  type= "crystal" \
  fields.values= "Boron=1e20 Germanium=2.0e22" \
  crystal.rate= "<100>=1.6000000000000001 <110>=1 <111>=0.27000000000000002" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_11_frontend_1_frontend_PMOS_SD_Epi_depo_epi_SiGeB_control_save_3D.tdr

deposit  \
  material= "Silicon" \
  rate= "0.002" \
  selective.materials= "SiGe SiGeB Silicon" \
  time= "1" \
  fields.values= "Boron=1e20 Germanium=2.0e22" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_12_frontend_1_frontend_PMOS_SD_Epi_depo_iso_SiGeB_control_save_3D.tdr

diffuse  \
  temp= "1000" \
  time= "1e-2<s>"

 # struct \ 
     # tdr.bnd=n@node@_13_frontend_1_frontend_PMOS_SD_Epi_diffuse_SiGeB_control_save_3D.tdr

# #split NMOS_SD_Epi

### NMOS_SD_Epi ###

deposit  \
  material= "Oxide3" \
  coord= "-0.18806" \
  type= "fill" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_NMOS_SD_Epi_depo_fill_oxide3_190nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 1:0 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_NMOS_SD_Epi_well_mask_m0"

mask  \
  name= "frontend_1_frontend_NMOS_SD_Epi_well_mask_m1" \
  bool= "bias(-0.02, frontend_1_frontend_NMOS_SD_Epi_well_mask_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_NMOS_SD_Epi_well_mask_m1"

 # struct \ 
     # tdr.bnd=n@node@_2_frontend_1_frontend_NMOS_SD_Epi_well_mask_control_save_3D.tdr

etch  \
  time= "0.25" \
  type= "anisotropic" \
  material= "Oxide3" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_3_frontend_1_frontend_NMOS_SD_Epi_etch_ellipso_oxide3_control_save_3D.tdr

etch  \
  time= "0.063" \
  type= "anisotropic" \
  material= "Nitride2" \
  rate= "1" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_4_frontend_1_frontend_NMOS_SD_Epi_etch_ellipso_spacer_nitride2_carbon_residue_control_save_3D.tdr

#_skip 

 # struct \ 
     # tdr.bnd=n@node@_5_frontend_1_frontend_NMOS_SD_Epi_etch_iso_nitride2_remove_sliver_control_save_3D.tdr

strip  \
   "Photoresist"

 # struct \ 
     # tdr.bnd=n@node@_6_frontend_1_frontend_NMOS_SD_Epi_etch_strip_resist_control_save_3D.tdr

# strip  \
#   "Oxide3"

 # struct \ 
     # tdr.bnd=n@node@_7_frontend_1_frontend_NMOS_SD_Epi_etch_strip_oxide3_control_save_3D.tdr

etch  \
  time= "1" \
  material= "Silicon" \
  rate= "0.040000000000000001" \
  type= "directional" \
  direction= "0.01 1 0" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_8_frontend_1_frontend_NMOS_SD_Epi_etch_directional_silicon_control_save_3D.tdr

etch  \
  material= "Silicon" \
  rate= "1" \
  type= "directional" \
  direction= "1 0 0" \
  time= "@<H-t_spacer-0.002>@" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_9_frontend_1_frontend_NMOS_SD_Epi_etch_aniso_silicon_control_save_3D.tdr

etch  \
  type= "isotropic" \
  material= "Silicon" \
  rate= "1" \
  type= "isotropic" \
  time= "@<t_spacer+0.002>@" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_10_frontend_1_frontend_NMOS_SD_Epi_etch_iso_trim_bottom_Si_control_save_3D.tdr

mgoals  \
  dx= "0.00050000000000000001" \
  dy= "0.00050000000000000001" \
  dz= "0.00050000000000000001"

deposit  \
  material= "Silicon" \
  selective.materials= "Silicon" \
  time= "0.059999999999999998" \
  type= "crystal" \
  fields.values= "Phosphorus=1e20" \
  crystal.rate= "<100>=1.6000000000000001 <110>=1 <111>=0.27000000000000002" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_11_frontend_1_frontend_NMOS_SD_Epi_depo_epi_SiliconN_control_save_3D.tdr

deposit  \
  material= "Silicon" \
  rate= "0.002" \
  selective.materials= "Silicon" \
  time= "1" \
  fields.values= "Phosphorus=1e20" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_12_frontend_1_frontend_NMOS_SD_Epi_depo_iso_SiliconN_control_save_3D.tdr

diffuse  \
  temp= "1000" \
  time= "1e-2<s>"

 # struct \ 
     # tdr.bnd=n@node@_13_frontend_1_frontend_NMOS_SD_Epi_diffuse_SiliconN_control_save_3D.tdr

strip  \
   "Carbon"

 # struct \ 
     # tdr.bnd=n@node@_14_frontend_1_frontend_NMOS_SD_Epi_etch_strip_Carbon_over_PMOS_control_save_3D.tdr

#_meas_CD 

 # struct \ 
     # tdr.bnd=n@node@_15_frontend_1_frontend_NMOS_SD_Epi_meas_CD_spacer_nitride2_fintop_control_save_3D.tdr

# #split Spacer2

### 2nd_Spacer ###

deposit  \
  material= "SiON" \
  rate= "1" \
  time= "0.0040000000000000001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_2nd_Spacer_depo_iso_SiON_3nm_control_save_3D.tdr

#_skip 

  struct  tdr.bnd=n@node@_2_frontend_1_frontend_2nd_Spacer_depo_iso_SiON_5nm_2_control_save_3D.tdr

etch  \
  time= "0.0245" \
  material= "SiON" \
  type= "anisotropic" \
  rate= "1" \
  !repair  \
  suppress.remesh 

etch  \
  time= "0.0005" \
  material= "SiON" \
  type= "isotropic" \
  rate= "1" \
  !repair  \
  suppress.remesh 


  struct  tdr.bnd=n@node@_3_frontend_1_frontend_2nd_Spacer_etch_aniso_SiON_control_save_3D.tdr

# #split Poly_Planarization

### Poly_Planarization ###

deposit  \
  material= "OxidePMD" \
  rate= "1" \
  time= "0.11" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_1_frontend_1_frontend_Poly_Planarization_depo_iso_oxidePMD_110nm_control_save_3D.tdr

etch  \
  material= "Oxide4 Oxide Oxide2 Oxide3 Nitride Nitride2 PolySilicon OxidePMD SiON SiliconN+ SiGe" \
  type= "cmp" \
  coord= "-0.0480603" \
  !repair  \
  suppress.remesh 

 # struct \ 
     # tdr.bnd=n@node@_2_frontend_1_frontend_Poly_Planarization_etch_cmp_all_50nm_control_save_3D.tdr

#split @HKMG@

### HKMG ###

strip  \
   "PolySilicon"

  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_HKMG_etch_strip_poly_gate_control_save_3D.tdr

etch  \
  time= "0.0050000000000000001" \
  type= "isotropic" \
  material= "Oxide" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_2_frontend_1_frontend_HKMG_etch_iso_oxide_control_save_3D.tdr

deposit  \
  material= "Oxide" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_3_frontend_1_frontend_HKMG_depo_iso_gate_oxide_1nm_control_save_3D.tdr

deposit  \
  material= "HfO2" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_4_frontend_1_frontend_HKMG_depo_iso_HfO2_1nm_control_save_3D.tdr
#if 0
deposit  \
  material= "TiN" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_5_frontend_1_frontend_HKMG_depo_iso_pWFM_TiN_1nm_control_save_3D.tdr

icwb.create.mask  \
  layer.name= 1:0 \
  shift= "0 0" \
  polarity= "negative" \
  name= "frontend_1_frontend_HKMG_nwell_mask_m0"

mask  \
  name= "frontend_1_frontend_HKMG_nwell_mask_m1" \
  bool= "bias(0, frontend_1_frontend_HKMG_nwell_mask_m0)"

photo  \
  thickness= "0.10000000000000001" \
  mask= "frontend_1_frontend_HKMG_nwell_mask_m1"

  # struct \ 
    # # tdr.bnd=n@node@_6_frontend_1_frontend_HKMG_nwell_mask_control_save_3D.tdr

etch  \
  time= "0.0040000000000000001" \
  type= "isotropic" \
  material= "TiN" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_7_frontend_1_frontend_HKMG_etch_iso_TiN_in_nmos_control_save_3D.tdr

strip  \
   "Photoresist"

  # struct \ 
    # # tdr.bnd=n@node@_8_frontend_1_frontend_HKMG_etch_strip_resist_control_save_3D.tdr

deposit  \
  material= "TiAlN" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_9_frontend_1_frontend_HKMG_depo_iso_nWFM_TiAlN_1nm_control_save_3D.tdr

deposit  \
  material= "TaN1" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_10_frontend_1_frontend_HKMG_depo_iso_TaN1_barrier_1nm_control_save_3D.tdr

deposit  \
  material= "TiN" \
  rate= "1" \
  time= "0.001" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_11_frontend_1_frontend_HKMG_depo_iso_TiN_liner_1nm_control_save_3D.tdr
#endif 
deposit  \
  material= "Tungsten" \
  rate= "1" \
  time= "0.050000000000000003" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_12_frontend_1_frontend_HKMG_depo_iso_W_50nm_control_save_3D.tdr

etch  \
  material= "HfO2 Oxide PolySilicon TaN TaN1 TiAlN TiN Tungsten" \
  type= "cmp" \
  coord= "-0.04806" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_13_frontend_1_frontend_HKMG_etch_cmp_all_50nm_control_save_3D.tdr

# #split  Gate_Recess_n_Etchstop

### Gate_Recess_n_Etchstop ###

etch  \
  time= "0.014999999999999999" \
  type= "isotropic" \
  material= "Tungsten" \
  rate= "1" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_1_frontend_1_frontend_Gate_Recess_n_Etchstop_etch_iso_gate_etchback_control_save_3D.tdr

deposit  \
  material= "SiON" \
  rate= "1" \
  time= "0.029999999999999999" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_2_frontend_1_frontend_Gate_Recess_n_Etchstop_depo_iso_SiON_30nm_cnt_etchstop_control_save_3D.tdr

etch  \
  material= "SiON" \
  type= "cmp" \
  coord= "-0.04806" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_3_frontend_1_frontend_Gate_Recess_n_Etchstop_etch_cmp_SiON_50nm_control_save_3D.tdr

deposit  \
  material= "OxidePMD2" \
  rate= "1" \
  time= "0.035000000000000003" \
  type= "isotropic" \
  !repair  \
  suppress.remesh 

  # struct \ 
    # # tdr.bnd=n@node@_4_frontend_1_frontend_Gate_Recess_n_Etchstop_depo_iso_OxidePMD_35nm_M0_PMD2_tapering_workaround_control_save_3D.tdr


#split @DeviceMesh@

#if "@Type@"=="nMOS"
region Oxide3 change.material name=OxidePMD_1
region Oxide3 change.material name=SiON_1 
#endif







icwb.create.mask  \
  layer.name= "3:201"\
  shift= "0 0" \
  polarity= "negative" \
  name= "gate_refinment_mask"

set gm_bbox [mask  \
  name= "gate_refinment_mask" \
  bbox ]
 
  
set mins [lindex $gm_bbox 0]
set maxs [lindex $gm_bbox 1]
set efffw @<W+0.002-H*tan((90-a_fin)*3.14159265359/180)>@
set hwbot1 @<W/2+(H/2+0.005)*tan((90-a_fin)*3.14159265359/180)>@
set hwbot2 @<W/2+(H/2+0.007)*tan((90-a_fin)*3.14159265359/180)>@
set hwtop @<W/2-H/2*tan((90-a_fin)*3.14159265359/180)>@
#if "@Type@"=="nMOS"
set side left 

set ygmax [lindex $mins 0]
set ygmax [expr ${ygmax}*1.0e4]
set ygmin [expr ${ygmax}-$efffw]
#else

set side right 
set ygmin [lindex $maxs 0]
set ygmin [expr ${ygmin}*1.0e4]
set ygmax [expr ${ygmin}+$efffw]

#endif


set zgmin  0.019
set zgmax [expr $zgmin +@L@/2 ]  

set ygcent [expr 0.5*($ygmin+$ygmax)]

puts "$ygmin $ygcent $ygmax $zgmin" 

transform cut location= -0.033 up

#strip  \
#  "Tungsten" 

#strip  \
#  "TiN" 

#strip  \
#  "TaN1"   
  
transform cut location= $ygcent $side


transform translate= {0 -$ygcent -$zgmax}  


#if "@Type@"=="pMOS"
transform reflect ymax !keep.original
#endif

refinebox clear
refinebox !keep.lines
line clear

set ygmax [expr $ygmax - $ygcent]
set ygmin [expr $ygmin - $ygcent]
set ygcent [expr $ygcent - $ygcent]

set zgmin [expr $zgmin - $zgmax]
set zgmax [expr $zgmax - $zgmax]

puts "zz $zgmin $zgmax"

line z loc= $zgmin  tag=leftgate
# line y loc= $hwtop  

set fd 1

# reset default settings for adaptive meshing
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

# Set high quality Delaunay meshes
pdbSet Grid sMesh 1
pdbSet Grid Adaptive 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh MaxPoints 2000000
pdbSet Grid SnMesh MaxNeighborRatio 3.0

pdbSet Grid SnMesh min.normal.size 1.0/$fd
pdbSet Grid SnMesh normal.growth.ratio.3d 1.0
pdbSet Grid SnMesh max.box.angle.3d 179

pdbSet Grid SnMesh Apply.Brep.DelPSC true

# Refinement strategy


set Zmin  [expr -0.033 -@L@/2+0.028/2]
set y2 [expr $ygmax+0.01]
set H @H@
set x1 [expr $H+0.01]
set x2 [expr $H+0.01] 
set zsp [expr $zgmin - @t_spacer@ - 0.002]

line z loc= $zsp  tag=leftspacer


puts "zzzz $Zmin $zgmin"


set Ymax 0.0164
set Xmin -0.033
set Xmax 0.3
set ff 1.0

# if 0

refinebox name=bott \
          min= "$H+0.005       $hwbot1             $Zmin" \
          max= "$H+0.007       $hwbot2             0" \
          xrefine= 0.001   materials= {Silicon SiliconGermanium}


refinebox name=All1 \
          min= "$Xmin         0              $Zmin" \
          max= "$Xmax        $Ymax          $zgmin" \
          xrefine= $Xmax/5/$ff yrefine= @W@/$ff    zrefine= @L@/2./$ff


refinebox name=eAll2 \
          min= "$Xmin         0              $zgmin" \
          max= "$Xmax        $Ymax          0" \
          xrefine= $Xmax/5/$ff yrefine= @W@/$ff    zrefine= @L@/2./$ff          


refinebox name=eSTI \
          min= "-0.017        0             $Zmin" \
          max= "0.1       $Ymax          $zgmin" \
          xrefine= 0.01/$ff yrefine= @W@/2./$ff    zrefine= @L@/4./$ff 

refinebox name=eSTI2 \
          min= "-0.017        0             $zgmin" \
          max= " 0.1        $Ymax             0" \
          xrefine= 0.01/$ff yrefine= @W@/2./$ff    zrefine= @L@/4./$ff    
          
refinebox name= DF1  \
	  min= "-0.07 0 $Zmin"\
	  max= "$x2 $y2 $zgmin" \
	  refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
          refine.max.edge= "0.005/$fd  0.005/$fd  0.005/$fd" refine.min.edge= "0.001/$fd  0.001/$fd  0.001/$fd" adaptive
		  
refinebox name= DF2  \
	  min= "-0.07 0 $zgmin"\
	  max= "$x2 $y2 0" \
	  refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
          refine.max.edge= "0.005/$fd  0.005/$fd  0.005/$fd" refine.min.edge= "0.001/$fd  0.001/$fd  0.001/$fd" adaptive

# #endif
          
#if 0                   
refinebox name= DF  \
	  min= "-0.0 0 $Zmin"\
	  max= "$x2 $hwbot 0" \
	  refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
          refine.max.edge= "0.005/$fd  0.005/$fd  0.005/$fd" refine.min.edge= "0.001/$fd  0.001/$fd  0.001/$fd" adaptive
	          
refinebox name= DG \
	  min= "-0.002 0 $zgmin-0.005"\
	  max= "$x2 $hwbot 0" \
          xrefine= "0.002/$fd"  yrefine= "0.001/$fd" zrefine= "0.001/$fd" materials= {Silicon SiliconGermanium}
#endif          
          
set y2 [expr $ygmax+0.005]


# #if 0
refinebox name= SDext \
           min= "-0.02 0 $Zmin" \
           max=  "$x2 $Ymax $zsp" \
           xrefine= 0.004  yrefine= 0.004 zrefine= 0.002 materials= {Silicon SiliconGermanium}

refinebox name= SpGate \
           min= "-0.005 0 $zsp" \
          max=  "$x2 $y2 $zgmin" \
           xrefine= 0.002  yrefine= 0.002 zrefine= 0.002 materials= {Silicon SiliconGermanium}
           
refinebox name= Gate \
          min= "-0.005 -0.01 $zgmin"\
          max=  "$x2 $y2 0"\
          xrefine= 0.002  yrefine= 0.002 zrefine= 0.002 materials= {Silicon SiliconGermanium}
# #endif        
set y2 [expr $ygmax+0.01]

refinebox name= DeviceIF \
          min= "-0.07 0 $Zmin" \
          max= "$x2 $y2 $zgmin" \
          min.normal.size= 0.0006/$fd normal.growth.ratio= 2.0 interface.materials= {Silicon Oxide SiliconGermanium Oxide }

refinebox name= DeviceIFg \
          min= "-0.07 0 $zgmin" \
          max= "$x2 $y2 0" \
          min.normal.size= 0.0005/$fd normal.growth.ratio= 1.5 interface.materials= {Silicon Oxide SiliconGermanium Oxide }

          
# refinebox name= DeviceIF2 \
#          min= "-0.0 0 $zgmin" \
#          max= "0.003 $y2 0" \
#          min.normal.size= 0.0002/$fd normal.growth.ratio= 1.5 interface.materials= {Silicon Oxide SiliconGermanium Oxide }


 grid remesh
#split @ElContacts@


set Zmin  [expr -0.033 -@L@/2+0.028/2]
set H @H@

set Ymax 0.0164
set Xmin -0.019
set Xmax 0.0023
          
# strip Oxide3

#etch  \
#  material= "Oxide3" \
#  type= "anisotropic" \
#  coord= "0.015" \
#  !repair  \
#  suppress.remesh 
# #if 0

# set topx [interface y=0.001 z=-0.001 Tungsten /Gas syntax.check.value=0.0]
# puts "topx = $topx"

#deposit  \
#  material= "Tungsten" \
#  type= "fill" \
#  coord = "$topx" \
#  !repair  \
#  suppress.remesh 

#  transform cut location= -0.028 up
# #endif


set Ymax 0.017
set Xmin -0.035
set Xmax 0.0023
set Zmin [expr $Zmin -0.01]
          
set mat1 Silicon
set mat Oxide3
#if "@Type@"=="pMOS"
set mat SiliconGermanium
#endif



polyhedron name=cont brick= "$Xmin 0  $Zmin $Xmax $Ymax 0"
insert polyhedron=cont new.material= Metal replace.materials= Oxide3
polyhedron clear


#contact add name=source  Silicon  box xlo=$Xmin xhi=$Xmax ylo=0 yhi=$Ymax zlo=$Zmin zhi=0 !replace adjacent.material= Oxide3 !cut.mesh

#contact add name=source  Nitride2  box xlo=$Xmin xhi=$Xmax ylo=0 yhi=$Ymax zlo=$Zmin zhi=0 !replace adjacent.material= Oxide3 !cut.mesh



 set zcont [expr $Zmin +0.011]

 contact add name=source Metal point  x="-0.023"  y="0.0005" z=$zcont replace 


 contact add name=gate Tungsten point  x="-0.00125"  y="0.0005" z=-0.0005 replace

 contact add name=substrate Silicon bottom !replace


struct   tdr.bnd=n@node@_half !Gas

#if "@Type@"=="nMOS"
region Gas change.material name=OxidePMD_1 
#elif "@Type@"=="pMOS"
region Gas change.material name=Oxide3_1 
#endif

## new commands from Paul to improve mesh
##pdbSet Grid SnMesh Apply.Brep.DelPSC false
##pdbSet Grid SnMesh MaxConnectivity 100
##grid remesh

#split @reflect@


struct  mshcmd tdr=n@node@_half !Gas

if { [catch { exec tdx -mtt -Z -ren source=drain n@node@_half_fps n@node@_fps} Err] !=0 } { 
    LogFile $Err
}
# Save

exit



