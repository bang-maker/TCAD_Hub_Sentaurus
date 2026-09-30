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

// implementation of the default band gap model using the PMI interface
class Default_BandGap : public PMI_BandGap {
private:
  double Eg0, alpha, beta;
public:
  Default_BandGap (const PMI_Environment& env);
  ~Default_BandGap ();
  void Compute_bg (const double t, double& bg);
  void Compute_dbgdt (const double t, double& dbgdt);
};

Default_BandGap::Default_BandGap (const PMI_Environment& env) :
PMI_BandGap (env)
{ // default values
  Eg0 = InitParameter ("Eg0", 1.16964);
  alpha = InitParameter ("alpha", 4.73e-4);
  beta = InitParameter ("beta", 636);
}

Default_BandGap::~Default_BandGap ()
{
}

void Default_BandGap::Compute_bg (const double t, double& bg)
{ bg = Eg0 - alpha * t * t / (t + beta);
}

void Default_BandGap::Compute_dbgdt (const double t, double& dbgdt)
{ dbgdt = - alpha * t * (t + 2.0 * beta) / ((t + beta) * (t + beta));
}

extern "C"
PMI_BandGap* new_PMI_BandGap (const PMI_Environment& env)
{ return new Default_BandGap (env);
}
