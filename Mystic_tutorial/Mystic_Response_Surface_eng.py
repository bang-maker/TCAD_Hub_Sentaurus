#setdep @node|Mystic_Uniform:all@

mystic_inputfile1 = "@pwd@/@nodedir@/pp@node@_mys.py1"
mystic_inputfile2 = "@pwd@/@nodedir@/pp@node@_mys.py2"
mystic_inputfile3 = "@pwd@/@nodedir@/pp@node@_mys.py3"
mystic_inputfile4 = "@pwd@/@nodedir@/pp@node@_mys.py4"
mystic_inputfile5 = "@pwd@/@nodedir@/pp@node@_mys.py5"
initial_modelcard = "@pwd@/@nodedir@/pp@node@_mys.mod"

# Set up flow-specific parameters
mystic.wait   = True
### ---------------------------------------------------------------- ###
node_prj.copy_metadata(dbi.get_project("@node|UploadData@"))
### ---------------------------------------------------------------- ###

# Calculate the midpoint node to use as "previous"
mid_prj_node = dbi.get_project(metadata__swb__Type="@Type@", \
                     metadata__swb__tool_label="Mystic_Uniform", \
                     metadata__midpoint=True)

previous_dataset=list(mid_prj_node.datasets)[-1].name

# Set up the Mystic inputs
mystic.inputfile  = mystic_inputfile1
mystic.args.model = None

# Execute Mystic 
mystic(previous=previous_dataset, dataset=f"{node}-RSM")
