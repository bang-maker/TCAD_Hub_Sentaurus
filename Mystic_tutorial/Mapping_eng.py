####################################################################################
# Python script to map parameters from the parent command file to their expected   #
# values in the child command file. This file is designed to reduce porting        # 
# requirements when moving between traditional TCAD command files and TCAD to      #
# SPICE command files. All parameters must be defined correctly here.        #
####################################################################################
from util_helpers import par_mapping


#if "@Type@" == "nMOS"
fac_n_to_p = 1
#elif "@Type@" == "pMOS"
fac_n_to_p = 1
#endif

############################################################
############# Device configuration parameters  #############
############################################################
# Ensure "Type" maps to n or p - example of remapping parameter names and values 
# simultaneously not currently possible as the incoming parameter and mapped ones 
# are the same
par_mapping(cval="Type",  pval={"Type":"@Type@"},     fac=None, val_remap={"nMOS":"n","pMOS":"p"})
par_mapping(cval="workfn",      pval={"WF":"@WF@"})
# Terminals - not defined in the parent command file, but are required here
par_mapping(cval="drain_con", pval={"None":"drain"})
par_mapping(cval="gate_con",  pval={"None":"gate"})
par_mapping(cval="source_con",  pval={"None":"source"})
par_mapping(cval="bulk_con",  pval={"None":"substrate"})
par_mapping(cval="acdrain_con", pval={"None":"drain"})
par_mapping(cval="acgate_con",  pval={"None":"gate"})
par_mapping(cval="acsource_con",pval={"None":"source"})
par_mapping(cval="acbulk_con",  pval={"None":"substrate"})

############################################################
################## Device bias parameters ##################
############################################################
par_mapping(cval="Vdd_nom", pval={"Vdd":"@Vdd@"},     fac=fac_n_to_p, val_remap=None)
par_mapping(cval="Vdd_lin", pval={"Vdd_Lin":"@Vdd_Lin@"},   fac=fac_n_to_p, val_remap=None)
par_mapping(cval="temp",  pval={"None":300})

############################################################
################### Geometric parameters ###################
############################################################
par_mapping(cval="lgate", pval={"L":"@L@"},     fac=1e-6) # convert to meters
par_mapping(cval="hfin",  pval={"H":"@H@"},     fac=1e-6) # convert to meters
par_mapping(cval="tfin",  pval={"W":"@W@"},     fac=1e-6) # convert to meters
# Extra DoE parameters
par_mapping(cval="afin",  pval={"a_fin":"@a_fin@"},   fac=1)
par_mapping(cval="tspacer", pval={"t_spacer":"@t_spacer@"},   fac=1e-6) # convert to meters

############################################################
################ Extra instance parameters #################
############################################################
par_mapping(cval="rsc",   pval={"rcx":"@rcx@"})
par_mapping(cval="rdc",   pval={"rcx":"@rcx@"})

