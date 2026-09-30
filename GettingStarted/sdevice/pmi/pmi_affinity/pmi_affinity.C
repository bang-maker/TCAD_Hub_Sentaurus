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

// implementation of the default affinity model using the PMI interface
class Default_Affinity : public PMI_Affinity {
private:
  double Affinity0, alpha, beta;
public:
  Default_Affinity (const PMI_Environment& env);
  ~Default_Affinity ();
  void Compute_affinity (const double t, double& affinity);
  void Compute_daffinitydt (const double t, double& daffinitydt);
};

Default_Affinity::
Default_Affinity (const PMI_Environment& env) :
PMI_Affinity (env)
{ // default values
  Affinity0 = InitParameter ("Affinity0", 4.05);  // affinity at 0K
  alpha = InitParameter ("alpha", 4.73e-4);
  beta = InitParameter ("beta", 636);
}

Default_Affinity::
~Default_Affinity ()
{
}

void Default_Affinity::
Compute_affinity (const double t, double& affinity)
{ affinity = Affinity0 + 0.5 * alpha * t * t / (t + beta);
}

void Default_Affinity::
Compute_daffinitydt (const double t, double& daffinitydt)
{ daffinitydt = 0.5 * alpha * t * (t + 2.0 * beta) / ((t + beta) * (t + beta));
}

extern "C"
PMI_Affinity* new_PMI_Affinity
(const PMI_Environment& env)
{ return new Default_Affinity (env);
}
