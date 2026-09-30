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

// implementation of Bennett-Wilson band gap narrowing using the PMI interface
class Bennett_BandGapNarrowing : public PMI_BandGapNarrowing {
private:
  double Ebgn, Nref;
public:
  Bennett_BandGapNarrowing (const PMI_Environment& env);
  ~Bennett_BandGapNarrowing ();
  void Compute_bgn
  (double& bgn);            // band bap narrowing
};

Bennett_BandGapNarrowing::Bennett_BandGapNarrowing (const PMI_Environment& env) :
PMI_BandGapNarrowing (env)
{ // default values
  Ebgn = InitParameter ("Ebgn", 6.84e-3);
  Nref = InitParameter ("Nref", 3.162e18);
}

Bennett_BandGapNarrowing::~Bennett_BandGapNarrowing ()
{
}

void Bennett_BandGapNarrowing::Compute_bgn (double& bgn)
{ const double Na = ReadDoping (PMI_Acceptor);
  const double Nd = ReadDoping (PMI_Donor);
  const double Ni = Na + Nd;
  if (Ni > Nref) {
    const double tmp = log (Ni / Nref);
    bgn = Ebgn * tmp * tmp;
  } else {
    bgn = 0.0;
  }
}

extern "C"
PMI_BandGapNarrowing* new_PMI_BandGapNarrowing (const PMI_Environment& env)
{ return new Bennett_BandGapNarrowing (env);
}
