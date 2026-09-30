/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include "PMI.h"

// implementation of Scharfetter (doping dependent) and
// temperature dependent lifetime using the PMI interface
class Scharfetter_Lifetime : public PMI_Lifetime_Base {
protected:
  const double T0;
  double taumin, taumax, Nref, gamma, Talpha;
public:
  Scharfetter_Lifetime(const PMI_Environment& env,
    const PMI_LifetimeModel model);
  ~Scharfetter_Lifetime ();
  void compute(const Input& input, Output& output);
};

Scharfetter_Lifetime::Scharfetter_Lifetime(const PMI_Environment& env,
  const PMI_LifetimeModel model) :
PMI_Lifetime_Base (env, model),
T0 (300.0)
{ }

Scharfetter_Lifetime::~Scharfetter_Lifetime()
{ }

void Scharfetter_Lifetime::compute(const Input& input, Output& output)
{ const pmi_float Ni = input.ReadDoping (PMI_Acceptor) + input.ReadDoping (PMI_Donor);
  output.tau = taumin + (taumax - taumin) / (1.0 + pow (Ni/Nref, gamma));
  output.tau *= pow (input.t/T0, Talpha);
}

class Scharfetter_e_Lifetime : public Scharfetter_Lifetime {
public:
  Scharfetter_e_Lifetime (const PMI_Environment& env,
    const PMI_LifetimeModel model);
  ~Scharfetter_e_Lifetime () {}
};

Scharfetter_e_Lifetime::Scharfetter_e_Lifetime(const PMI_Environment& env,
  const PMI_LifetimeModel model) :
Scharfetter_Lifetime (env, model)
{ // default values
  taumin = InitParameter ("taumin_e", 0.0);
  taumax = InitParameter ("taumax_e", 1.0e-5);
  Nref = InitParameter ("Nref_e", 1.0e16);
  gamma = InitParameter ("gamma_e", 1.0);
  Talpha = InitParameter ("Talpha_e", -1.5);
}

class Scharfetter_h_Lifetime : public Scharfetter_Lifetime {
public:
  Scharfetter_h_Lifetime (const PMI_Environment& env,
    const PMI_LifetimeModel model);
  ~Scharfetter_h_Lifetime () {}
};

Scharfetter_h_Lifetime::Scharfetter_h_Lifetime(const PMI_Environment& env,
  const PMI_LifetimeModel model) :
Scharfetter_Lifetime (env, model)
{ // default values
  taumin = InitParameter ("taumin_h", 0.0);
  taumax = InitParameter ("taumax_h", 3.0e-6);
  Nref = InitParameter ("Nref_h", 1.0e16);
  gamma = InitParameter ("gamma_h", 1.0);
  Talpha = InitParameter ("Talpha_h", -1.5);
}

extern "C"
PMI_Lifetime_Base* new_PMI_e_Lifetime_Base
(const PMI_Environment& env, const PMI_LifetimeModel model)
{ return new Scharfetter_e_Lifetime (env, model);
}

extern "C"
PMI_Lifetime_Base* new_PMI_h_Lifetime_Base
(const PMI_Environment& env, const PMI_LifetimeModel model)
{ return new Scharfetter_h_Lifetime (env, model);
}
