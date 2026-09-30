#setdep @node|Mystic_Response_Surface:all@ 
#if @node:index@ == 1
from randomspice.rslibrary.builder import BuildLibrary
builder=BuildLibrary(dbi, lib_type="SUBCKT")

remap_names={"nMOS":"nfet","pMOS":"pfet"}
node_prj.metadata.update({"remap_names":remap_names})
node_prj.save()

################################################################
### The following code is for the midpoint of the DoE only.  ###
### These base model cards will be the basis for the         ###
### response surface model and the variability model.        ###
################################################################
midpoints = {p.metadata["swb"]["Type"]:p for p in dbi.get_project(metadata__midpoint=True, metadata__swb__tool_label="Mystic_Uniform_Enigma")}

for proj in midpoints.values():

    remap_name=remap_names[proj.metadata["swb"]["Type"]]
    # Add base model card
    builder.add_device(remap_name, dev_type=proj.metadata["swb"]["Type"], dataset=list(proj.datasets)[-1], point_model=False)

###############################################################
### The following code is to add response surface models    ###
### corresponding to each DoE point.                        ###
###############################################################
rs_projects = dbi.get_project(metadata__swb__tool_label="Mystic_Response_Surface")
for proj in rs_projects:

    doe_pt=proj.metadata["doe"]
    doe_pt.update({"nfin":1})

    dev_midpoint = remap_names[proj.metadata["swb"]["Type"]]
    # Add RSM model points
    builder.add_doe_point(dev_midpoint, doe_pt, dataset=list(proj.datasets)[-1], midpoint=proj.metadata["midpoint"])

################################################################
#### The following code is to add process generators.       ####
#### In this case, this is for (Lg and Tfin).               ####
################################################################
# Set up the prototye of the DoE axes headers,
# should look like: LG_N237_N
axis1_header = "@axis1@_{0}_{1}" # L
axis2_header = "@axis2@_{0}_{1}" # HFIN
axis3_header = "@axis3@_{0}_{1}" # HFIN
axis4_header = "@axis4@_{0}_{1}" # AFIN
axis5_header = "@axis5@_{0}_{1}" # TSPACER
device1 = remap_names["nMOS"]
device2 = remap_names["pMOS"]
device1_type = "nmos"
device2_type = "pmos"


# Build the list of the headers
# The header should be 2*(No of DoE axes) length
headers = [axis1_header.format(device1,device1_type), axis1_header.format(device2,device2_type),\
           axis2_header.format(device1,device1_type), axis2_header.format(device2,device2_type),\
           axis3_header.format(device1,device1_type), axis3_header.format(device2,device2_type),\
           axis4_header.format(device1,device1_type), axis4_header.format(device2,device2_type),\
           axis5_header.format(device1,device1_type), axis5_header.format(device2,device2_type)]

# This is added manually for now
          # NLg,  PLg,  NTFIN, PTFIN, NHFIN, PHFIN, NAFIN, PAFIN, NTSPACER, PTSPACER
means   = [25e-9,  25e-9,  40e-9,  40e-9,  8e-9,   8e-9,   88,  88,  8e-9,   8e-9] 
stdv	= [0.4e-9, 0.4e-9, 0.4e-9, 0.4e-9, 0.4e-9, 0.4e-9, 0.2, 0.2, 0.4e-9, 0.4e-9]
              # NLg,  PLg,  NTFIN, PTFIN, NHFIN, PHFIN, NAFIN, PAFIN, NTSPACER, PTSPACER
corr_matrix = [[1.0,  0.9,  0.05,  0.05,  0.05,  0.05,  0.05,  0.05,  0.05,     0.05],	#NLg   corr w/PLg = 0.9
               [0.9,  1.0,  0.05,  0.05,  0.05,  0.05,  0.05,  0.05,  0.05,     0.05],  #PLg   corr w/NLg = 0.9
               [0.05, 0.05, 1.0,   0.5,   0.05,  0.05,  0.05,  0.05,  0.05,     0.05],  #NHFIN corr w/PHFIN = 0.5
               [0.05, 0.05, 0.5,   1.0,   0.05,  0.05,  0.05,  0.05,  0.05,     0.05],  #PHFIN corr w/NHFIN = 0.5
               [0.05, 0.05, 0.05,  0.05,  1.0,   0.95,  0.05,  0.05,  0.05,     0.05],  #NTFIN corr w/PTFIN = 0.95
               [0.05, 0.05, 0.05,  0.05,  0.95,  1.0,   0.05,  0.05,  0.05,     0.05],  #PTFIN corr w/NTFIN = 0.95
               [0.05, 0.05, 0.05,  0.05,  0.05,  0.05,  1.0,   0.05,  0.05,     0.05],  #NAFIN corr w/PAFIN = 0.05
               [0.05, 0.05, 0.05,  0.05,  0.05,  0.05,  0.05,  1.0,   0.05,     0.05],  #PAFIN corr w/NAFIN = 0.05
               [0.05, 0.05, 0.05,  0.05,  0.05,  0.05,  0.05,  0.05,  1.0,      0.15],  #NTSPACER corr w/PTSPACER = 0.15
               [0.05, 0.05, 0.05,  0.05,  0.05,  0.05,  0.05,  0.05,  0.15,     1.0 ]]  #PTSPACER corr w/NTSPACER = 0.15


builder.add_gv_distributions(device1, device2, headers=headers, sigmas=stdv, means=means,corr_matrix=corr_matrix, all_parameters=None)


print("building")
# Save the library
builder.build("@pwd@/@nodedir@", libname="{0}".format("n@node@_library"), doe=True, gv_dist=True, lv_dist=False, debug=True, non_unif_gv=False)

#else
#noexec
#endif
