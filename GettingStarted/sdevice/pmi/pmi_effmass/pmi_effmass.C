/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <math.h>
#include <stdlib.h>

#include "PMIModels.h"

// implementation of a linear effective mass model using the PMI interface
class Linear_EffectiveMass : public PMI_EffectiveMass {
protected:
  double mass_300, dmass_dt;
public:
  Linear_EffectiveMass (const PMI_Environment& env);
  ~Linear_EffectiveMass ();
  void Compute_m (const double t, const double bg, double& m);
  void Compute_dmdt (const double t, const double bg, double& dmdt);
  void Compute_dmdbg (const double t, const double bg, double& dmdbg);
};

Linear_EffectiveMass::Linear_EffectiveMass (const PMI_Environment& env) :
PMI_EffectiveMass (env) { }

Linear_EffectiveMass::~Linear_EffectiveMass () { }

void Linear_EffectiveMass::Compute_m (const double t, const double bg, double& m)
{ m = mass_300 + dmass_dt * (t - 300.0);
}

void Linear_EffectiveMass::Compute_dmdt (const double t, const double bg, 
  double& dmdt)
{ 
  dmdt = dmass_dt;
}

void Linear_EffectiveMass::Compute_dmdbg (const double t, const double bg, 
  double& dmdbg)
{ 
  dmdbg = 0.0;
}

class Linear_e_EffectiveMass : public Linear_EffectiveMass {
public:
  Linear_e_EffectiveMass (const PMI_Environment& env);
  ~Linear_e_EffectiveMass () {}
};

Linear_e_EffectiveMass::Linear_e_EffectiveMass (const PMI_Environment& env) :
Linear_EffectiveMass (env)
{ // default values
  mass_300 = InitParameter ("mass_e_300", 1.09);
  dmass_dt = InitParameter ("dmass_e_dt", 1.6e-4);
}

class Linear_h_EffectiveMass : public Linear_EffectiveMass {
public:
  Linear_h_EffectiveMass (const PMI_Environment& env);
  ~Linear_h_EffectiveMass () {}
};

Linear_h_EffectiveMass:: Linear_h_EffectiveMass (const PMI_Environment& env) :
Linear_EffectiveMass (env)
{ // default values
  mass_300 = InitParameter ("mass_h_300", 1.15);
  dmass_dt = InitParameter ("dmass_h_dt", 9.2e-4);
}

extern "C"
PMI_EffectiveMass* new_PMI_e_EffectiveMass
(const PMI_Environment& env)
{ return new Linear_e_EffectiveMass (env);
}

extern "C"
PMI_EffectiveMass* new_PMI_h_EffectiveMass
(const PMI_Environment& env)
{ return new Linear_h_EffectiveMass (env);
}
