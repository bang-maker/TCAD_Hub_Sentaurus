/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include <stdlib.h>

#include "PMIModels.h"

// implementation of Auger recombination using the PMI interface
class Auger_Recombination : public PMI_Recombination {
  double C;
public:
  Auger_Recombination(const PMI_Environment& env);
  ~Auger_Recombination();
  void Compute_r
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& r);            // recombination rate
  void Compute_drdt
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& drdt);         // derivative of recombination rate
                            // with respect to lattice temperature
  void Compute_drdn
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& drdn);         // derivative of recombination rate
                            // with respect to electron density
  void Compute_drdp
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& drdp);         // derivative of recombination rate
                            // with respect to hole density
  void Compute_drdnie
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& drdnie);       // derivative of recombination rate
                            // with respect to effective intrinsic density
  void Compute_drdf
    (const double t,        // lattice temperature
     const double n,        // electron density
     const double p,        // hole density
     const double nie,      // effective intrinsic density
     const double f,        // absolute value of electric field
     double& drdf);         // derivative of recombination rate
                            // with respect to absolute value of electric field
};

Auger_Recombination::Auger_Recombination(const PMI_Environment& env) :
  PMI_Recombination(env)
{ 
  C = InitParameter("C", 1e-30);
  std::cout << "PMI: C=" << C << "\n";
}

Auger_Recombination::~Auger_Recombination()
{ }

void Auger_Recombination::Compute_r(const double t, const double n, const double p,
           const double nie, const double f, double& r)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  r = -1e15 * f * f;
#else
  // Auger recombination
  r = C * (n + p) * (n*p - nie*nie);
  if (r < 0.0) {
    r = 0.0;
  }
#endif
}

void Auger_Recombination::Compute_drdt(const double t, const double n, const double p,
              const double nie, const double f, double& drdt)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  drdt = 0.0;
#else
  // Auger recombination
  drdt = 0.0;
#endif
}

void Auger_Recombination::Compute_drdn(const double t, const double n, const double p,
              const double nie, const double f, double& drdn)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  drdn = 0.0;
#else
  // Auger recombination
  double r = C * (n + p) * (n*p - nie*nie);
  if (r < 0.0) {
    drdn = 0.0;
  } else {
    drdn = C * ((n*p - nie*nie) + (n + p) * p);
  }
#endif
}

void Auger_Recombination::Compute_drdp(const double t, const double n, const double p,
              const double nie, const double f, double& drdp)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  drdp = 0.0;
#else
  // Auger recombination
  double r = C * (n + p) * (n*p - nie*nie);
  if (r < 0.0) {
    drdp = 0.0;
  } else {
    drdp = C * ((n*p - nie*nie) + (n + p) * n);
  }
#endif
}

void Auger_Recombination::Compute_drdnie(const double t, const double n, const double p,
                const double nie, const double f, double& drdnie)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  drdnie = 0.0;
#else
  // Auger recombination
  double r = C * (n + p) * (n*p - nie*nie);
  if (r < 0.0) {
    drdnie = 0.0;
  } else {
    drdnie = C * (n + p) * (- 2.0 * nie);
  }
#endif
}

void Auger_Recombination::Compute_drdf(const double t, const double n, const double p,
              const double nie, const double f, double& drdf)
{
#ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
  // test case for dependence on electric field
  drdf = -1e15 * 2.0 * f;
#else
  // Auger recombination
  drdf = 0.0;
#endif
}

extern "C" {
  PMI_Recombination* new_PMI_Recombination(const PMI_Environment& env)
  { return new Auger_Recombination(env);
  }
  
  int PMI_Recombination_ElectricField()
  {
    #ifdef PMI_RECOMB_TEST_ELECTRIC_FIELD_DEPENDENCE
    // test case for dependence on electric field
    return 1;
    #else
    // Auger recombination
    // model does not depend on electric field
    return 0;
    #endif
  }
}
