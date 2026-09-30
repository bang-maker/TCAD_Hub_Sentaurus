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



// implementation of the Canali mobility model using the PMI interface
class Canali_HighFieldMobility : public PMI_HighFieldMobility {

private:

  // container for temporary data used in parallel mobility calculations
  class TempData {
  public:
    double beta, vsat, Fabs, val, valb, valb1, valb11b;
  };

  void Compute_internal (TempData& data,
                         const double t, const double mulow, const double F);

protected:
  const double T0;
  double beta0, betaexp, vsat0, vsatexp;

public:
  Canali_HighFieldMobility (const PMI_Environment& env,
                            const PMI_HighFieldDrivingForce force,
                            const PMI_AnisotropyType anisotype);

  ~Canali_HighFieldMobility ();

  void Compute_mu
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& mu);             // mobility

  void Compute_dmudpot
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudpot);        // derivative of mobility
                              // with respect to electrostatic potential

  void Compute_dmudn
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudn);          // derivative of mobility
                              // with respect to electron density

  void Compute_dmudp
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudp);          // derivative of mobility
                              // with respect to hole density

  void Compute_dmudt
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudt);          // derivative of mobility
                              // with respect to lattice temperature

  void Compute_dmudct
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudct);         // derivative of mobility
                              // with respect to carrier temperature

  void Compute_dmudmulow
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudmulow);      // derivative of mobility
                              // with respect to low field mobility

  void Compute_dmudF
    (const double pot,        // electrostatic potential
     const double n,          // electron density
     const double p,          // hole density
     const double t,          // lattice temperature
     const double ct,         // carrier temperature
     const double mulow,      // low field mobility
     const double F,          // driving force
     double& dmudF);          // derivative of mobility
                              // with respect to driving force

};



void Canali_HighFieldMobility::
Compute_internal (TempData& data,
                  const double t, const double mulow, const double F)

{ data.beta = beta0 * pow (t/T0, betaexp);
  data.vsat = vsat0 * pow (t/T0, -vsatexp);
  data.Fabs = fabs (F);
  data.val = mulow * data.Fabs / data.vsat;
  data.valb = data.val > 0 ? pow (data.val, data.beta) : 0;
  data.valb1 = 1.0 + data.valb;
  data.valb11b = pow (data.valb1, 1.0/data.beta);
}



Canali_HighFieldMobility::
Canali_HighFieldMobility (const PMI_Environment& env,
                          const PMI_HighFieldDrivingForce force,
                          const PMI_AnisotropyType anisotype) :
  PMI_HighFieldMobility (env, force, anisotype),
  T0 (300.0)

{
}



Canali_HighFieldMobility::
~Canali_HighFieldMobility ()

{
}



void Canali_HighFieldMobility::
Compute_mu (const double pot, const double n,
            const double p, const double t, const double ct,
            const double mulow, const double F, double& mu)

{ TempData data;
  Compute_internal (data, t, mulow, F);
  mu = mulow / data.valb11b;
}



void Canali_HighFieldMobility::
Compute_dmudpot (const double pot, const double n,
                 const double p, const double t, const double ct,
                 const double mulow, const double F, double& dmudpot)

{ dmudpot = 0.0;
}



void Canali_HighFieldMobility::
Compute_dmudn (const double pot, const double n,
               const double p, const double t, const double ct,
               const double mulow, const double F, double& dmudn)

{ dmudn = 0.0;
}



void Canali_HighFieldMobility::
Compute_dmudp (const double pot, const double n,
               const double p, const double t, const double ct,
               const double mulow, const double F, double& dmudp)

{ dmudp = 0.0;
}



void Canali_HighFieldMobility::
Compute_dmudt (const double pot, const double n,
               const double p, const double t, const double ct,
               const double mulow, const double F, double& dmudt)

{ TempData data;
  Compute_internal (data, t, mulow, F);
  const double mu = mulow / data.valb11b;

  const double dmudbeta = mu * (log (data.valb1) / (data.beta*data.beta) -
                                data.valb * log (data.val) /
                                (data.beta * data.valb1));
  const double dmudvsat = (mu * data.valb) / (data.valb1 * data.vsat);
  const double dbetadt = data.beta * betaexp / t;
  const double dvsatdt = -data.vsat * vsatexp / t;

  dmudt = dmudbeta * dbetadt + dmudvsat * dvsatdt;
}



void Canali_HighFieldMobility::
Compute_dmudct (const double pot, const double n,
                const double p, const double t, const double ct,
                const double mulow, const double F, double& dmudct)

{ dmudct = 0.0;
}



void Canali_HighFieldMobility::
Compute_dmudmulow (const double pot, const double n,
                   const double p, const double t, const double ct,
                   const double mulow, const double F, double& dmudmulow)

{ TempData data;
  Compute_internal (data, t, mulow, F);
  dmudmulow = 1.0 / (data.valb1 * data.valb11b);
}



void Canali_HighFieldMobility::
Compute_dmudF (const double pot, const double n,
               const double p, const double t, const double ct,
               const double mulow, const double F, double& dmudF)

{ TempData data;
  Compute_internal (data, t, mulow, F);
  const double mu = mulow / data.valb11b;
  const double signF = (F >= 0.0) ? 1.0 : -1.0;

  dmudF = -mu * pow (mulow/data.vsat, data.beta) *
          pow (data.Fabs, data.beta-1.0) * signF / data.valb1;
}



class Canali_e_HighFieldMobility : public Canali_HighFieldMobility {

public:
  Canali_e_HighFieldMobility (const PMI_Environment& env,
                              const PMI_HighFieldDrivingForce force,
                              const PMI_AnisotropyType anisotype);

  ~Canali_e_HighFieldMobility () {}

};



Canali_e_HighFieldMobility::
Canali_e_HighFieldMobility (const PMI_Environment& env,
                            const PMI_HighFieldDrivingForce force,
                            const PMI_AnisotropyType anisotype) :
  Canali_HighFieldMobility (env, force, anisotype)

{ // default values
  beta0 = InitParameter ("beta0_e", 1.109);
  betaexp = InitParameter ("betaexp_e", 0.66);
  vsat0 = InitParameter ("vsat0_e", 1.07e7);
  vsatexp = InitParameter ("vsatexp_e", 0.87);
}



class Canali_h_HighFieldMobility : public Canali_HighFieldMobility {

public:
  Canali_h_HighFieldMobility (const PMI_Environment& env,
                              const PMI_HighFieldDrivingForce force,
                              const PMI_AnisotropyType anisotype);

  ~Canali_h_HighFieldMobility () {}

};



Canali_h_HighFieldMobility::
Canali_h_HighFieldMobility (const PMI_Environment& env,
                            const PMI_HighFieldDrivingForce force,
                            const PMI_AnisotropyType anisotype) :
  Canali_HighFieldMobility (env, force, anisotype)

{ // default values
  beta0 = InitParameter ("beta0_h", 1.213);
  betaexp = InitParameter ("betaexp_h", 0.17);
  vsat0 = InitParameter ("vsat0_h", 8.37e6);
  vsatexp = InitParameter ("vsatexp_h", 0.52);
}



extern "C"
PMI_HighFieldMobility* new_PMI_HighField_e_Mobility
  (const PMI_Environment& env, const PMI_HighFieldDrivingForce force,
   const PMI_AnisotropyType anisotype)

{ return new Canali_e_HighFieldMobility (env, force, anisotype);
}



extern "C"
PMI_HighFieldMobility* new_PMI_HighField_h_Mobility
  (const PMI_Environment& env, const PMI_HighFieldDrivingForce force,
   const PMI_AnisotropyType anisotype)

{ return new Canali_h_HighFieldMobility (env, force, anisotype);
}
