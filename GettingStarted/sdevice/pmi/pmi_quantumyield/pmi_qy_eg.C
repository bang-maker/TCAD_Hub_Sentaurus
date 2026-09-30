/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include "PMI.h"

class EgStepQuantumYield : public PMI_OpticalQuantumYield_Base {
public:
  EgStepQuantumYield(const PMI_Environment& env);
  ~EgStepQuantumYield(){}

  virtual void compute(const Input& input, Output& output);
};

EgStepQuantumYield::EgStepQuantumYield(const PMI_Environment& env)
  : PMI_OpticalQuantumYield_Base(env)
{
}

namespace {

  pmi_float mu2eV(pmi_float lambda)
  {
    static const pmi_float h_planck = 6.626176e-34;
    static const pmi_float C_LIGHT = 2.997925e10;
    static const pmi_float e0 =  1.602192e-19;
    return h_planck*C_LIGHT/e0/lambda*1e4;
  }

}

void EgStepQuantumYield::compute(const Input& input, Output& output)
{
  pmi_float wavelength_eV(mu2eV(input.wavelength));
  output.eta_G = (ReadRegionMaterialGroup() == semiconductor ? 1. : 0.) * 
    (wavelength_eV >= input.bg ? 1. : 0.) * 
    (input.cplxExtCoeff > 0. ? (1. - input.d_k_carr / input.cplxExtCoeff) : 1.);
  output.eta_T_Eg = output.eta_G;
  output.eta_T0 = 1. - output.eta_G;
}

extern "C"
PMI_OpticalQuantumYield_Base* new_PMI_OpticalQuantumYield_Base(const PMI_Environment& env)
{
  return new EgStepQuantumYield(env);
}
