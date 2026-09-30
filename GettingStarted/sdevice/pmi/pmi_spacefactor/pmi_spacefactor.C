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

// implementation of a user space factor field for traps using the PMI interface
class pmi_spacefactor : public PMI_SpaceFactor {
public:
  pmi_spacefactor(const PMI_Environment& env);
  ~pmi_spacefactor();
  void Compute_spacefactor(double& spacefactor);
};

pmi_spacefactor::pmi_spacefactor(const PMI_Environment& env) :
  PMI_SpaceFactor(env)
{ }

pmi_spacefactor::~pmi_spacefactor()
{ }

void pmi_spacefactor::Compute_spacefactor(double& spacefactor)
{ spacefactor = ReadUserField(PMI_UserField1);
}

extern "C"
PMI_SpaceFactor* new_PMI_SpaceFactor
  (const PMI_Environment& env)
{ return new pmi_spacefactor (env);
}
