/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <iostream>
using std::cerr;
using std::endl;

#include <cmath>
#include <cstdlib>

#include "PMIModels.h"

// implementation of the Lombardi mobility model using the PMI interface
class Lombardi_EnormalMobility : public PMI_EnormalMobility {
protected:
  const double T0;
  const int ElectrostaticPotential_index;
  const int eDensity_index;
  const int hDensity_index;
  double B, C, lambda, delta, eta, l_crit;
public:
  Lombardi_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_EnormalMobility();
  void Compute_muinv
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& muinv);             // inverse of mobility degradation
  void Compute_dmuinvdpot
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdpot);        // derivative of muinv
                                // with respect to electrostatic potential
  void Compute_dmuinvdenorm
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdenorm);      // derivative of muinv
                                // with respect to normal electric field
  void Compute_dmuinvdn
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdn);          // derivative of muinv
                                // with respect to electron density
  void Compute_dmuinvdp
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdp);          // derivative of muinv
                                // with respect to hole density
  void Compute_dmuinvdt
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdt);          // derivative of muinv
                                // with respect to lattice temperature
  void Compute_dmuinvdct
  (const double dist,          // distance to nearest interface
    const double pot,           // electrostatic potential
    const double enorm,         // normal electric field
    const double n,             // electron density
    const double p,             // hole density
    const double t,             // lattice temperature
    const double ct,            // carrier temperature
    double& dmuinvdct);         // derivative of muinv
                                // with respect to carrier temperature
};

Lombardi_EnormalMobility::Lombardi_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
PMI_EnormalMobility(env, type, anisotype),
T0(300.0),
ElectrostaticPotential_index(FieldName2Index("ElectrostaticPotential")),
eDensity_index(FieldName2Index("eDensity")),
hDensity_index(FieldName2Index("hDensity"))
{ }

Lombardi_EnormalMobility::~Lombardi_EnormalMobility()
{ }

void Lombardi_EnormalMobility::Compute_muinv(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& muinv)
{ const double Ni = ReadDoping(PMI_Donor) + ReadDoping(PMI_Acceptor);
  const double denom_ac_inv =
  B + pow(enorm, 2.0/3.0) * C * pow(Ni, lambda) * T0 / t;
  const double mu_ac_inv = enorm / denom_ac_inv;
  const double mu_sr_inv = enorm * enorm / delta + pow(enorm, 3.0) / eta;
  const double damping = exp(-dist/l_crit);
  muinv = damping * (mu_ac_inv + mu_sr_inv);
  
  double x, y, z;
  ReadCoordinate(x, y, z);
  // check of Sentaurus Device fields
  const double pot2 = ReadField(ElectrostaticPotential_index);
  if (pot2 != pot) {
    cerr << "error in field \"ElectrostaticPotential\":" << endl;
    cerr << "    x                      = " << x << endl;
    cerr << "    y                      = " << y << endl;
    cerr << "    ElectrostaticPotential = " << pot2 << endl;
    cerr << "    pot                    = " << pot << endl;
    exit(1);    
  }
  const double n2 = ReadField(eDensity_index);
  if (n2 != n) {
    cerr << "error in field \"eDensity\":" << endl;
    cerr << "    x        = " << x << endl;
    cerr << "    y        = " << y << endl;
    cerr << "    eDensity = " << n2 << endl;
    cerr << "    n        = " << n << endl;
    exit(1);    
  }
  const double p2 = ReadField(hDensity_index);
  if (p2 != p) {
    cerr << "error in field \"hDensity\":" << endl;
    cerr << "    x        = " << x << endl;
    cerr << "    y        = " << y << endl;
    cerr << "    hDensity = " << p2 << endl;
    cerr << "    p        = " << p << endl;
    exit(1);    
  }
}

void Lombardi_EnormalMobility::Compute_dmuinvdpot(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdpot)
{ dmuinvdpot = 0.0;
}

void Lombardi_EnormalMobility::Compute_dmuinvdenorm(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdenorm)
{ const double Ni = ReadDoping(PMI_Donor) + ReadDoping(PMI_Acceptor);
  const double denom_ac_inv =
  B + pow(enorm, 2.0/3.0) * C * pow(Ni, lambda) * T0 / t;
  const double dmu_ac_inv_denorm =
  (2.0 * B + denom_ac_inv) / (3.0 * denom_ac_inv * denom_ac_inv);
  
  const double mu_sr_inv_denorm =
  2.0 * enorm / delta + 3.0 * enorm * enorm / eta;
  
  const double damping = exp(-dist/l_crit);
  dmuinvdenorm = damping * (dmu_ac_inv_denorm + mu_sr_inv_denorm);
}

void Lombardi_EnormalMobility::Compute_dmuinvdn(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdn)
{ dmuinvdn = 0.0;
}

void Lombardi_EnormalMobility::Compute_dmuinvdp(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdp)
{ dmuinvdp = 0.0;
}

void Lombardi_EnormalMobility::Compute_dmuinvdt(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdt)
{ const double Ni = ReadDoping(PMI_Donor) + ReadDoping(PMI_Acceptor);
  const double factor = pow(enorm, 2.0/3.0) * C * pow(Ni, lambda) * T0;
  const double denom_ac_inv = B + factor / t;
  const double dmu_ac_inv_dt =
  enorm * factor / (denom_ac_inv * denom_ac_inv * t * t);
  
  const double damping = exp(-dist/l_crit);
  dmuinvdt = damping * dmu_ac_inv_dt;
}

void Lombardi_EnormalMobility::Compute_dmuinvdct(const double dist, const double pot,
  const double enorm, const double n, const double p,
  const double t, const double ct, double& dmuinvdct)
{ dmuinvdct = 0.0;
}

class Lombardi_e_EnormalMobility : public Lombardi_EnormalMobility {
public:
  Lombardi_e_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_e_EnormalMobility() {}
};

Lombardi_e_EnormalMobility::Lombardi_e_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
Lombardi_EnormalMobility(env, type, anisotype)
{ // default values
  B = InitParameter("B_e", 4.750e7);
  C = InitParameter("C_e", 580.0);
  lambda = InitParameter("lambda_e", 0.125);
  delta = InitParameter("delta_e", 5.82e14);
  eta = InitParameter("eta_e", 5.82e30);
  l_crit = InitParameter("l_crit_e", 1.0e-6);
}

class Lombardi_h_EnormalMobility : public Lombardi_EnormalMobility {
public:
  Lombardi_h_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_h_EnormalMobility() {}
};

Lombardi_h_EnormalMobility::Lombardi_h_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
Lombardi_EnormalMobility(env, type, anisotype)
{ // default values
  B = InitParameter("B_h", 9.925e6);
  C = InitParameter("C_h", 2947.0);
  lambda = InitParameter("lambda_h", 0.0317);
  delta = InitParameter("delta_h", 2.0546e14);
  eta = InitParameter("eta_h", 2.0546e30);
  l_crit = InitParameter("l_crit_h", 1.0e-6);
}

extern "C"
PMI_EnormalMobility* new_PMI_Enormal_e_Mobility
(const PMI_Environment& env, const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype)
{ return new Lombardi_e_EnormalMobility(env, type, anisotype);
}

extern "C"
PMI_EnormalMobility* new_PMI_Enormal_h_Mobility
(const PMI_Environment& env, const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype)
{ return new Lombardi_h_EnormalMobility(env, type, anisotype);
}
