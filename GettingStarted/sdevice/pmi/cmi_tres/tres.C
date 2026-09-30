#include <cstdlib>
#include <cstring>
#include <iostream>
#include <cmath>
#include "CMIModels.h"
#include "CMISupport.h"

class Parameters {
public:
  double r; // resistance
  double alpha; // linear temperature coefficient
  double beta; // quadratic temperature coefficient
  double tref; // reference temperature
  Parameters ();
  void Set (const CCMBaseParam* param);
  void Get (CCMBaseParam* param);
};

Parameters::Parameters () :
r (1.0),
alpha (0.0),
beta (0.0),
tref (300.15)
{}

void Parameters::Set (const CCMBaseParam* param) { 
  if (param->Defined ()) {
    if (strcmp (param->Name (), "r") == 0) {
      r = *param;
    } else if (strcmp (param->Name (), "alpha") == 0) {
      alpha = *param;
    } else if (strcmp (param->Name (), "beta") == 0) {
      beta = *param;
    } else if (strcmp (param->Name (), "tref") == 0) {
      tref = *param;
    }
  }
}

void Parameters::Get (CCMBaseParam* param) {
  if (strcmp (param->Name (), "r") == 0) {
    *param = r;
    param->Defined (1);
  } else if (strcmp (param->Name (), "alpha") == 0) {
    *param = alpha;
    param->Defined (1);
  } else if (strcmp (param->Name (), "beta") == 0) {
    *param = beta;
    param->Defined (1);
  } else if (strcmp (param->Name (), "tref") == 0) {
    *param = tref;
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
};

extern "C" void cmi_device_create (CCMBaseDevice*const device) { 
  device->device_desc = new Device;
}

extern "C" void cmi_device_set_param (CCMBaseDevice*const device,
  const CCMBaseParam*const param) 
{
  Device* dev = (Device*) device->device_desc;
  dev->par.Set (param);
}

extern "C" void cmi_device_initialize (CCMBaseDevice*const device) {}

extern "C" void cmi_device_get_param (CCMBaseDevice*const device,
  CCMBaseParam*const param) 
{
  Device* dev = (Device*) device->device_desc;
  dev->par.Get (param);
}

extern "C" void cmi_device_delete (CCMBaseDevice*const device) {
  delete (Device*) device->device_desc;
}

extern "C" void cmi_pset_create (CCMBasePSet*const pset) {
  pset->pset_desc = new PSet;
}

extern "C" void cmi_pset_set_param (CCMBasePSet*const pset,
  const CCMBaseParam*const param) 
{
  PSet* ps = (PSet*) pset->pset_desc;
  ps->par.Set (param);
}

extern "C" void cmi_pset_initialize (CCMBasePSet*const pset) {}

extern "C" void cmi_pset_get_param (CCMBasePSet*const pset,
  CCMBaseParam*const param)
{ 
  PSet* ps = (PSet*) pset->pset_desc;
  ps->par.Get (param);
}

extern "C" void cmi_pset_delete (CCMBasePSet*const pset) {
  delete (PSet*) pset->pset_desc;
}

extern "C" void cmi_instance_create (CCMBaseInstance*const instance) {
  instance->instance_desc = new Instance;
}

extern "C" void cmi_instance_set_param (CCMBaseInstance*const instance,
  const CCMBaseParam*const param)
{ 
  Instance* inst = (Instance*) instance->instance_desc;
  inst->par.Set (param);
}

extern "C" void cmi_instance_initialize (CCMBaseInstance*const instance) {
  Instance* inst = (Instance*) instance->instance_desc;
}

extern "C" void cmi_instance_get_param (CCMBaseInstance*const instance,
  CCMBaseParam*const param)
{ 
  Instance* inst = (Instance*) instance->instance_desc;
  inst->par.Get (param);
}
#define u1 (variables [0])
#define u2 (variables [1])
#define t1 (variables [2])
#define i (variables [3])
extern "C" void cmi_instance_get_rhs (CCMBaseInstance*const instance,
  const int dc, const double time,
  const double*const variables,
  double*const rhs)
{ 
  Instance* inst = (Instance*) instance->instance_desc;
  if (dc) {
    double dT = t1 - inst->par.tref;
    double R = inst->par.r *
    (1.0 + (inst->par.alpha + inst->par.beta * dT) * dT);
    rhs [0] = i;
    rhs [1] = -i;
    rhs [2] = -(u1 - u2) * i;
    rhs [3] = u1 - u2 - R * i;
  } else {
    rhs [0] = 0.0;
    rhs [1] = 0.0;
    rhs [2] = 0.0;
    rhs [3] = 0.0;
  }
}

extern "C" void cmi_instance_get_jacobian (CCMBaseInstance*const instance,
  const int dc, const double time,
  const double*const variables,
  double*const*const jacobian)
{ 
  Instance* inst = (Instance*) instance->instance_desc;
  if (dc) {
    double dT = t1 - inst->par.tref;
    double R = inst->par.r *
    (1.0 + (inst->par.alpha + inst->par.beta * dT) * dT);
    double dRdt1 = inst->par.r *
    (inst->par.alpha + 2.0 * inst->par.beta * dT);
    jacobian[0][3] = 1.0;
    jacobian[1][3] = -1.0;
    jacobian[2][0] = -i;
    jacobian[2][1] = i;
    jacobian[2][3] = u2 - u1;
    jacobian[3][0] = 1.0;
    jacobian[3][1] = -1.0;
    jacobian[3][2] = -i*dRdt1;
    jacobian[3][3] = -R;
  }
}

extern "C" int
cmi_instance_is_physical (CCMBaseInstance*const instance,
  const double time,
  const double*const variables) {  return 1; }

extern "C" void
cmi_instance_delete (CCMBaseInstance*const instance) {
  delete (Instance*) instance->instance_desc;
}