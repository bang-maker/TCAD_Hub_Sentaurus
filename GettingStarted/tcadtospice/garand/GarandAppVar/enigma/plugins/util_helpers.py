import os
from libfromage.data import Data
import pandas as pd
import copy

def par_mapping(cval, pval, fac=None, val_remap=None):
    ''' 
    Quick prototype, won't even do data validation for now
    '''
    
    # pull out the name of the parent parameter
    pname=list(pval.keys())[0]

    # cant remap to the same name
    if cval==pname: 
        print(f"Warning: original parameter name {pname} and mapped parameter name {cval} match, skipping remap")
        return

    # cant scale and remap values
    elif fac is not None and val_remap is not None:
         raise ValueError("No logic to apply correction factor and remap simultaneously")

    else:
        # check for remap values
        if val_remap is not None:
            if pval[pname] not in list(val_remap.keys()):
                print(f"Warning: value {pval[pname]} not in val_remap list {val_remap.keys()}, remapping ignored.")
                fval=pval[pname]
            else:
                fval=val_remap[pval[pname]]
        else:
            fval=pval[pname]

        if fac is not None:
            try:
                fval=float(fval)*float(fac)
            except TypeError:
                print(f"Warning: cannot apply factor:{fac} to value:{fval}.")

        try:
            retstr=f"DOE: {cval} {fval:.12g}"
        except ValueError:
            retstr=f"DOE: {cval} {fval}"
        print(retstr)



def set_work_dir(projectpath, node):
    ''' 
    Quick prototype, won't even do data validation for now
    '''
    if int(os.environ.get("SWB_HIERARCHICAL_PROJECT_DIR")) == 0:
        # not in heirachical mode
        return (os.path.join(projectpath, "n{node}_".format(node=node)))
    elif int(os.environ.get("SWB_HIERARCHICAL_PROJECT_DIR")) == 1:
        return (os.path.join(projectpath, "results", "nodes", str(node)))




@classmethod
def concat(cls, items, sort=False):
    # check input is iterable
    if not hasattr(items, "__iter__"): raise ValueError("Supplied items must be itterable.")

    # setup placeholders for new DF values
    newindex=copy.deepcopy(items[0].index.tolist())
    newvals={}
    for c in items[0].columns:
        newvals[c]=items[0][c].values.tolist()

    # save the ivar teminal, used to be exculded from bias checking
    ivar_term=items[0].var_name[1:]    

    # check metadata matches
    for x,i in enumerate(items):
        if not isinstance(i, Data): raise ValueError("Can't concat non Data objects.")

        if str(i.index.name) != str(items[0].index.name):
            raise ValueError(f"Can't match index {i.index.name} and {items[0].index.name}.")

        elif i.columns.tolist() != items[0].columns.tolist():
            raise ValueError(f"Can't match columns {i.columns.tolist()} and {items[0].columns.tolist()}.")

        for k,v in i.metadata.items():
             if k == "bias":
                 i_biases=i.metadata['bias']
                 r_biases=items[0].metadata['bias']
                 for b in list(i_biases.keys()):
                     if b == ivar_term:
                         pass
                     elif i_biases[b] != r_biases[b]:
                         raise ValueError(f"Can't match biases for {b}, {i_biases[b]} and {r_biases[b]}.")
             elif i.metadata[k] != items[0].metadata[k]:
                 raise ValueError(f"Can't match metadata {i.metadata[k]} and {items[0].metadata[k]}.")

        # if all passes update our DF placeholders
        if x != 0:
            newindex+=i._variables
            for c in items[0].columns:
                newvals[c]+=i[c].values.tolist()

    # build a new Data object
    df=pd.DataFrame(newvals, index=newindex)
    df.index.name=items[0].var_name
    if sort == True:
        df.sort_index(inplace=True)
    df.reset_index(inplace=True)
    data1=cls(df, ivar=items[0].var_name, metadata=copy.deepcopy(items[0].metadata))

    return data1

Data.concat=concat



