#setdep @node|UploadData@

#if "@midpoint@" == "True"

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

# Stage 1 (LD)
mystic.inputfile  = mystic_inputfile1
mystic.args.model = initial_modelcard
mystic(previous=None,   dataset=f"{node}-low-drain")

# Stage 2 (HD)
mystic.inputfile  = mystic_inputfile2
mystic.args.model = None
mystic(previous=f"{node}-low-drain", dataset=f"{node}-high-drain")

# Stage 3 (CV)
mystic.inputfile  = mystic_inputfile3
mystic.args.model = None
mystic(previous=f"{node}-high-drain", dataset=f"{node}-cv")

# Stage 4 (NOTUSED)
##mystic.inputfile  = mystic_inputfile4
##mystic.args.model = None
##mystic()

# Stage 5 (NOTUSED)
##mystic.inputfile  = mystic_inputfile5
##mystic.args.model = None
##mystic()

#else 
#noexec
#endif



