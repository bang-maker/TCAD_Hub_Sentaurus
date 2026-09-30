## Example RandomSpice processing script.
from libfromage.frontend import DBInterface
from libfromage.data import Data
import pandas as pd

pd.set_option("mode.chained_assignment",None)

def Process(data, **extras):
    results = extras['results']
    circuit = extras['cid']
    vals= list()
    output=False
    d0=[]
    d1=[]
    for l in data.split("\n"):
        if len(l) > 0:
            if 'cyc_freq' in l.lower():
                try:
                    freq=float(l.replace('=',' ').split()[1])
                except:
                    print("Failed to read frequency value from line: {0}".format(l))
            elif 'sw_pwr' in l.lower():
                try:
                    pwr=float(l.replace('=',' ').split()[1])
                except:
                    print("Failed to read power value from line: {0}".format(l))
            elif 'iddq' in l.lower():
                try:
                    leakage=float(l.replace('=',' ').split()[1])
                except:
                    print("Failed to read leakage value from line: {0}".format(l))


    data={"freq":freq, "pwr":pwr, "leakage":leakage, "circuit":circuit}

    dbi = results._dbi
    ds=dbi.get_dataset(id=results._set_id).name

    dbi.create_data(ds, data)

    return data

