/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include "PMI.h"

static pmi_float Max (pmi_float a, pmi_float b)
{ if (a >= b) {
    return a;
  }
  return b;
}

// implementation of the Masetti mobility model using the PMI interface
class Masetti_DopingDepMobility : public PMI_DopingDepMobility_Base {
protected:
  const double T0;
  double mumax, Exponent, mumin1, mumin2, mu1, Pc, Cr, Cs, alpha, beta;
public:
  Masetti_DopingDepMobility(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype);
  ~Masetti_DopingDepMobility() {}
  void compute(const Input& input, Output& output);
};

Masetti_DopingDepMobility::Masetti_DopingDepMobility(const PMI_Environment& env,
                           const PMI_AnisotropyType anisotype) :
  PMI_DopingDepMobility_Base (env, anisotype),
  T0 (300.0)
{ }

void Masetti_DopingDepMobility::compute(const Input& input, Output& output)
{
#if 0
  // straightforward implementation
  const pmi_float mu_const = mumax * pow (input.t/T0, -Exponent);
  const pmi_float Ni = Max (input.donor + input.acceptor, 1.0);
  output.m = mumin1 * exp (-Pc / Ni) +
             (mu_const - mumin2) / (1.0 + pow (Ni / Cr, alpha)) -
             mu1 / (1.0 + pow (Cs / Ni, beta));
#else
  // optimized implementation
  pmi_float mu_const (input.t);
  mu_const.div (T0).pow (-Exponent).mul (mumax);

  pmi_float Ni (input.donor);
  Ni.add (input.acceptor);
  if (Ni < 1.0) {
    Ni = 1.0;
  }

  output.m = -Pc;
  output.m.div (Ni).exp ().mul (mumin1);

  pmi_float tmp1 (Ni);
  tmp1.div (Cr).pow (alpha).add (1.0);
  mu_const.sub (mumin2).div (tmp1);

  pmi_float tmp3 (Cs);
  tmp3.div (Ni).pow (beta).add (1.0);
  pmi_float tmp4 (mu1);
  tmp4.div (tmp3);

  output.m.add (mu_const).sub (tmp4);
#endif
}

class Masetti_e_DopingDepMobility : public Masetti_DopingDepMobility {
public:
  Masetti_e_DopingDepMobility (const PMI_Environment& env,
                               const PMI_AnisotropyType anisotype);
  ~Masetti_e_DopingDepMobility () {}
};

Masetti_e_DopingDepMobility::Masetti_e_DopingDepMobility(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype) :
  Masetti_DopingDepMobility (env, anisotype)
{ // default values
  mumax = InitParameter ("mumax_e", 1417.0);
  Exponent = InitParameter ("Exponent_e", 2.5);
  mumin1 = InitParameter ("mumin1_e", 52.2);
  mumin2 = InitParameter ("mumin2_e", 52.2);
  mu1 = InitParameter ("mu1_e", 43.4);
  Pc = InitParameter ("Pc_e", 0.0);
  Cr = InitParameter ("Cr_e", 9.68e16);
  Cs = InitParameter ("Cs_e", 3.43e20);
  alpha = InitParameter ("alpha_e", 0.680);
  beta = InitParameter ("beta_e", 2.0);
}

class Masetti_h_DopingDepMobility : public Masetti_DopingDepMobility {
public:
  Masetti_h_DopingDepMobility (const PMI_Environment& env,
                               const PMI_AnisotropyType anisotype);
  ~Masetti_h_DopingDepMobility () {}
};

Masetti_h_DopingDepMobility::Masetti_h_DopingDepMobility(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype) :
  Masetti_DopingDepMobility (env, anisotype)
{ // default values
  mumax = InitParameter ("mumax_h", 470.5);
  Exponent = InitParameter ("Exponent_h", 2.2);
  mumin1 = InitParameter ("mumin1_h", 44.9);
  mumin2 = InitParameter ("mumin2_h", 0.0);
  mu1 = InitParameter ("mu1_h", 29.0);
  Pc = InitParameter ("Pc_h", 9.23e16);
  Cr = InitParameter ("Cr_h", 2.23e17);
  Cs = InitParameter ("Cs_h", 6.10e20);
  alpha = InitParameter ("alpha_h", 0.719);
  beta = InitParameter ("beta_h", 2.0);
}

extern "C"
PMI_DopingDepMobility_Base* new_PMI_DopingDep_e_Mobility_Base
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new Masetti_e_DopingDepMobility (env, anisotype);
}

extern "C"
PMI_DopingDepMobility_Base* new_PMI_DopingDep_h_Mobility_Base
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new Masetti_h_DopingDepMobility (env, anisotype);
}
