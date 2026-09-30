
import mystic.CompactModelTarget.CircuitData
import mystic.Database.DB 
import common.optimisers.fitter
import numpy as np


def copy(self):
    return mystic.CompactModelTarget.CircuitData.SimData(name=self._name, nodes=self._nodes, set_id=self._dataset_id)
    
def store(self, data, parameters, ensemble_id=0, description=None, error=None, extra_params=None):
    self.StoreFitParameters(parameters, ensemble_id=ensemble_id, extra_params=extra_params)
    if isinstance(data, mystic.CompactModelTarget.CircuitData.SimData):
        data = [data]
    for sd in data:
        for d in sd:
            d.to_db(self.dataset, nodes=sd._nodes) 

def wrap(params, target, param_cache=None, error_cache=None):
    pars = [p for p in params if not isinstance(p, common.optimisers.Parameter.LinkedOptimisationParameter)]
    linked_pars = list(set(pars).symmetric_difference(params))
    def new_target(x, *args, **kwargs):
        for i,p in enumerate(pars):
            p.scaled_value = x[i]

        if param_cache is not None:
            param_cache.append(x)
        
        errs = target(pars+linked_pars, *args, **kwargs)
               
        if error_cache is not None:
            error_cache.append(np.array(errs))    
            
        return errs

    return new_target
            
mystic.CompactModelTarget.CircuitData.SimData.copy = copy
mystic.Database.DB.MysticDB.StoreFitData = store      
common.optimisers.fitter.wrap_params = wrap  
