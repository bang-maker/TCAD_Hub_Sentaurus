/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include <math.h>

#include "PMIModels.h"

static double Max (double a, double b)
{ if (a >= b) {
    return a;
  }
  return b;
}

// implementation of the Masetti mobility model using the PMI interface
class Masetti_DopingDepMobility : public PMI_DopingDepMobility {
protected:
  const double T0;
  double mumax, Exponent, mumin1, mumin2, mu1, Pc, Cr, Cs, alpha, beta;
public:
  Masetti_DopingDepMobility(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype);
  ~Masetti_DopingDepMobility() {}
  void Compute_m
    (const double n,        // electron density
     const double p,        // hole density
     const double t,        // lattice temperature
     double& m);            // doping dependent mobility
  void Compute_dmdn
    (const double n,        // electron density
     const double p,        // hole density
     const double t,        // lattice temperature
     double& dmdn);         // derivative of doping dependent mobility
                            // with respect to electron density
  void Compute_dmdp
    (const double n,        // electron density
     const double p,        // hole density
     const double t,        // lattice temperature
     double& dmdp);         // derivative of doping dependent mobility
                            // with respect to hole density
  void Compute_dmdt
    (const double n,        // electron density
     const double p,        // hole density
     const double t,        // lattice temperature
     double& dmdt);         // derivative of doping dependent mobility
                            // with respect to lattice temperature
};

Masetti_DopingDepMobility::Masetti_DopingDepMobility(const PMI_Environment& env,
                           const PMI_AnisotropyType anisotype) :
  PMI_DopingDepMobility (env, anisotype),
  T0 (300.0)
{ }

void Masetti_DopingDepMobility::Compute_m(const double n, const double p,
           const double t, double& m)
{ const double mu_const = mumax * pow (t/T0, -Exponent);
  const double Ni = Max (ReadDoping (PMI_Donor) + ReadDoping (PMI_Acceptor), 1.0);
  m = mumin1 * exp (-Pc / Ni) +
      (mu_const - mumin2) / (1.0 + pow (Ni / Cr, alpha)) -
      mu1 / (1.0 + pow (Cs / Ni, beta));
}

void Masetti_DopingDepMobility::Compute_dmdn(const double n, const double p,
              const double t, double& dmdn)
{ dmdn = 0.0;
}

void Masetti_DopingDepMobility::Compute_dmdp(const double n, const double p,
              const double t, double& dmdp)
{ dmdp = 0.0;
}

void Masetti_DopingDepMobility::Compute_dmdt(const double n, const double p,
              const double t, double& dmdt)
{ const double Ni = Max (ReadDoping (PMI_Donor) + ReadDoping (PMI_Acceptor), 1.0);
  dmdt = mumax * (-Exponent/T0) * pow (t/T0, -Exponent - 1.0) /
         (1.0 + pow (Ni / Cr, alpha));
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
PMI_DopingDepMobility* new_PMI_DopingDep_e_Mobility
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new Masetti_e_DopingDepMobility (env, anisotype);
}

extern "C"
PMI_DopingDepMobility* new_PMI_DopingDep_h_Mobility
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new Masetti_h_DopingDepMobility (env, anisotype);
}
