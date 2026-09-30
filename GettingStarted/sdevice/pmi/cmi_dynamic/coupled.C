/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

// coupled inductances, dynamically linked to Sentaurus Device
// compile with "cmi coupled.C"

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "CMIModels.h"
#include "CMISupport.h"

class Parameters {
public:
  double ind1;
  double ind2;
  double k;
  Parameters ();
  void Set (const CCMBaseParam* param);
  void Get (CCMBaseParam* param);
};

Parameters::Parameters () :
  ind1 (0.0),
  ind2 (0.0),
  k (1.0)
{
}

void Parameters::Set (const CCMBaseParam* param)
{ if (param->Defined ()) {
    if (strcmp (param->Name (), "ind1") == 0) {
      ind1 = *param;
    } else if (strcmp (param->Name (), "ind2") == 0) {
      ind2 = *param;
    } else if (strcmp (param->Name (), "k") == 0) {
      k = *param;
    }
  }
}

void Parameters::Get (CCMBaseParam* param)
{ if (strcmp (param->Name (), "ind1") == 0) {
    *param = ind1;
    param->Defined (1);
  } else if (strcmp (param->Name (), "ind2") == 0) {
    *param = ind2;
    param->Defined (1);
  } else if (strcmp (param->Name (), "k") == 0) {
    *param = k;
    param->Defined (1);
  } else {
    param->Defined (0);
  }
}

class Device {
public:
  Parameters par;
};

class PSet {
public:
  Parameters par;
};

class Instance {
public:
  Parameters par;
  double m;
};

extern "C" void
cmi_device_create (CCMBaseDevice*const device)
{ device->device_desc = new Device;
}

extern "C" void
cmi_device_set_param (CCMBaseDevice*const device,
                      const CCMBaseParam*const param)

{ Device* dev = (Device*) device->device_desc;
  dev->par.Set (param);
}

extern "C" void
cmi_device_initialize (CCMBaseDevice*const device)
{
}

extern "C" void
cmi_device_get_param (CCMBaseDevice*const device,
                      CCMBaseParam*const param)
{ Device* dev = (Device*) device->device_desc;
  dev->par.Get (param);
}

extern "C" void
cmi_device_delete (CCMBaseDevice*const device)
{ delete (Device*) device->device_desc;
}

extern "C" void
cmi_pset_create (CCMBasePSet*const pset)
{ pset->pset_desc = new PSet;
}

extern "C" void
cmi_pset_set_param (CCMBasePSet*const pset,
                    const CCMBaseParam*const param)
{ PSet* ps = (PSet*) pset->pset_desc;
  ps->par.Set (param);
}

extern "C" void
cmi_pset_initialize (CCMBasePSet*const pset)
{
}

extern "C" void
cmi_pset_get_param (CCMBasePSet*const pset,
                    CCMBaseParam*const param)
{ PSet* ps = (PSet*) pset->pset_desc;
  ps->par.Get (param);
}

extern "C" void
cmi_pset_delete (CCMBasePSet*const pset)
{ delete (PSet*) pset->pset_desc;
}

extern "C" void
cmi_instance_create (CCMBaseInstance*const instance)
{ instance->instance_desc = new Instance;
}

extern "C" void
cmi_instance_set_param (CCMBaseInstance*const instance,
                        const CCMBaseParam*const param)
{ Instance* inst = (Instance*) instance->instance_desc;
  inst->par.Set (param);
}

extern "C" void
cmi_instance_initialize (CCMBaseInstance*const instance)
{ Instance* inst = (Instance*) instance->instance_desc;
  inst->m = inst->par.k * sqrt (inst->par.ind1 * inst->par.ind2);
}

extern "C" void
cmi_instance_get_param (CCMBaseInstance*const instance,
                        CCMBaseParam*const param)
{ Instance* inst = (Instance*) instance->instance_desc;
  inst->par.Get (param);
}

#define u1 (variables [0])
#define u2 (variables [1])
#define u3 (variables [2])
#define u4 (variables [3])
#define i1 (variables [4])
#define i2 (variables [5])

extern "C" void
cmi_instance_get_rhs (CCMBaseInstance*const instance,
                      const int dc, const double time,
                      const double*const variables,
                      double*const rhs)
{ Instance* inst = (Instance*) instance->instance_desc;
  if (dc) {
    rhs [0] = i1;
    rhs [1] = -i1;
    rhs [2] = i2;
    rhs [3] = -i2;
    rhs [4] = u1-u2;
    rhs [5] = u3-u4;
  } else {
    rhs [4] = -inst->par.ind1 * i1 - inst->m * i2;
    rhs [5] = -inst->par.ind2 * i2 - inst->m * i1;
    // check of callback into Sentaurus Device
    double starttime = cmi_starttime ();
  }
}

extern "C" void
cmi_instance_get_jacobian (CCMBaseInstance*const instance,
                           const int dc, const double time,
                           const double*const variables,
                           double*const*const jacobian)
{ Instance* inst = (Instance*) instance->instance_desc;
  if (dc) {
    jacobian[0][4] = 1.0;
    jacobian[1][4] = -1.0;
    jacobian[2][5] = 1.0;
    jacobian[3][5] = -1.0;
    jacobian[4][0] = 1.0;
    jacobian[4][1] = -1.0;
    jacobian[5][2] = 1.0;
    jacobian[5][3] = -1.0;
  } else {
    jacobian[4][4] = -inst->par.ind1;
    jacobian[4][5] = -inst->m;
    jacobian[5][4] = -inst->m;
    jacobian[5][5] = -inst->par.ind2;
  }
}

extern "C" int
cmi_instance_is_physical (CCMBaseInstance*const instance,
                          const double time,
                          const double*const variables)
{ return 1;
}

extern "C" void
cmi_instance_delete (CCMBaseInstance*const instance)
{ delete (Instance*) instance->instance_desc;
}
