#if @node:index@ == 1

from enigma.commands import startdb, stopdb
from randomspice.rslibrary.builder import BuildLibrary

builder = BuildLibrary(dbi=None, lib_type="SUBCKT", legacy=True)

# Data containers used in RS2 simulations
midpoint_metadata = {}
axes_df = pd.DataFrame()
remap_names = {"nMOS": "nfet", "pMOS": "pfet"}

# Parent project paths
mysticProjectPaths = ["@pwd@/../14nmFinFETRespSurf_NoLV"]

for prj in mysticProjectPaths:

    startdb(prj)
    # Switch database connection
    dburl = open(f"{prj}/enigma/mongodb.conf").read()
    dbi.connect(dburl)
    builder.dbi = dbi

    ################################################################
    ### The following code is for the midpoint of the DoE only.  ###
    ### These base model cards will be the basis for the         ###
    ### response surface model and the variability model.        ###
    ################################################################
    midpoint_projects = dbi.get_project(midpoint=True,
                                        swb__tool_label="Mystic_Uniform_Enigma")
    midpoint_metadata.update({p.metadata["swb"]["Type"]: p.metadata
                              for p in midpoint_projects})

    for proj in midpoint_projects:
        remap_name = remap_names[proj.metadata["swb"]["Type"]]
        # Add base model card
        builder.add_device(remap_name, dev_type=proj.metadata["swb"]["Type"],
                           dataset=list(proj.datasets)[-1], point_model=False)

    print("Base SPICE models")
    print(builder.base_modelcards)

    ###############################################################
    ### The following code adds response surface models         ###
    ### corresponding to each DoE point.                        ###
    ###############################################################
    rs_projects = dbi.get_project(swb__tool_label="Mystic_Response_Surface")

    for proj in rs_projects:
        axis_data = pd.DataFrame(proj.metadata['doe'], index=[0])
        axes_df = pd.concat([axes_df, axis_data])

        doe_pt = proj.metadata["doe"]
        doe_pt.update({"nfin": 1})

        dev_midpoint = remap_names[proj.metadata["swb"]["Type"]]
        # Add RSM model points
        builder.add_doe_point(dev_midpoint, doe_pt,
                              dataset=list(proj.datasets)[-1],
                              midpoint=proj.metadata["midpoint"])

    print("RSM table")
    print(builder.resp_dict)
    stopdb(prj)

print("building")
# Save the library
builder.build("@pwd@/@nodedir@", libname="n@node@_library", doe=True,
              gv_dist=False, lv_dist=False, debug=True)

# Switch database connection to current Sentaurus Workbench project
dburl = open("@pwd@/enigma/mongodb.conf").read()
dbi.connect(dburl)
builder.dbi = dbi

## This code is here to avoid database metadata
## queries in the RandomSpice stages.
node_prj.metadata.update({"axes_df": axes_df})
node_prj.metadata.update({"midpoint_metadata": midpoint_metadata})
node_prj.metadata.update({"remap_names": remap_names})
node_prj.save()

#else
#noexec
#endif
