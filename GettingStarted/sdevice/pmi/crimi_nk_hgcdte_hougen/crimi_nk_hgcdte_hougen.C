/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

This CRIMI implements an analytik model for n&K values for Hg(1-x)Cd(x)Te
The model was calibrated in the temperature range 80k-300K for IR - 5-15um.
For more details see C.A. Hougen, J.Appl. Phys. 66(8), 15 Oct. 1989, p 3763.

*/

#include "CRIModels.h"
#include <iostream>
#include <cstdlib>
#include <cmath> 

using namespace std;

namespace opto_n_cri {
  const double SpeedOfLight = 299792458; // [m/s]
  const double BoltzmannConstant = 6.626176e-34; // [Js]
  const double PlanckConstant = 1.380662e-23; // [J/K]
  const double ElectronCharge = 1.6021892e-19; // [C]
  const double kq = PlanckConstant / ElectronCharge; // [eV K^-1]
  const double Pi = 3.141592654; // 1
  
  class Constant_CRI_Model : public CRI_Model {
  private:
    string myName;
    int formula;
  public:
    Constant_CRI_Model(const CRI_Environment& env);
    ~Constant_CRI_Model();
    void Compute_n(double& n);
    void Compute_k(double& k);
  };
  
  Constant_CRI_Model::Constant_CRI_Model(const CRI_Environment& env) : CRI_Model(env) {
    myName = Name();
    formula = InitParameter("Formula",3);
    #ifdef DEBUG
    cout << "CRI " << myName << ": init\n";
    #endif    
    #ifdef DEBUG
    cout <<"============================================================\n";
    printf("CRI model %s for HgCdTe (region: %s material: %s)\n", myName.c_str(),  ReadRegionName().c_str(), ReadMaterialName().c_str());
    cout <<"============================================================\n";
    printf("%-6s:% d ||\n", "Formula", formula);
    #endif
    RegisterVariableToRead("xMoleFraction");
  }
  
  Constant_CRI_Model::~Constant_CRI_Model() {
    #ifdef DEBUG
    cout << "CRI_Model: delete\n";
    #endif
  }
  
  void Constant_CRI_Model::Compute_n(double& n) {
    if (formula == 2) {
      n = Read_n();
      return;
    }
    double x = ReadVariableValue("xMoleFraction");; // 1
    double A = 16.4135-22.1914*x+11.081*x*x;
    double B = 0.037514+1.060482*x+0.876032*x*x;
    double C = 0.5694*pow(x, -1.5355);
    double D = -1.4917e-3+2.1144e-3*x-1.0415e-3*x*x;
    double E = -1.63e-7;
    double wlength = min(ReadWavelength(),1.17*C);
    double n2 = A + B/(1-(C/wlength)*(C/wlength)) + D*wlength*wlength + E*pow(wlength,4.);
    if (n2 < 1) {
      cout<<"Error: n < 1 setting n = 1\n";
      n = 1;
    } else {
      n = sqrt(n2);
    }
    #ifdef DEBUG
    printf("CRI %s: x = %.3g, wavelength = %.3g um, n = %.4g\n", myName.c_str(), x, wlength, n); 
    #endif
  }
  
  void Constant_CRI_Model::Compute_k(double& k) {
    if (formula == 1) {
      k = Read_k();
      return;
    }
    double x = ReadVariableValue("xMoleFraction");; // 1
    double T = ReadTemperature(); // K
    double wlength = ReadWavelength();
    double PhotonE = BoltzmannConstant*SpeedOfLight/(1e-6*wlength)/ElectronCharge; // eV
    double AT = 100.0+5000.0*x;
    double A0 = exp(-18.88+53.61*x);
    double S = 3.267e4*(1.0+x);
    double E0 = -0.3424+1.838*x;
    double T0 = 81.9;
    double LN = log(AT/A0);
    double ST = S/(T+T0);
    double phE0 = E0+LN/ST;
    double A = 0;
    if(PhotonE < phE0) {
      A = A0* exp((PhotonE-E0)*ST);
    } else {
      A = AT * sqrt(2.0*ST)*sqrt(PhotonE-E0-(LN-0.5)/ST);
    }
    k = wlength*1.e-6/(4*Pi)*A/1.e-2;
    #ifdef DEBUG
    printf("CRI %s: T = %.4g K Wavelength = %.4g um PhotonE = %.4g eV\n", myName.c_str(), T, ReadWavelength(), PhotonE); 
    printf("CRI %s: k = %.4g alpha: %.4g cm^-1\n", myName.c_str(), k, A); 
    #endif
  }
}

extern "C" {
  
  opto_n_cri::CRI_Model* 
  new_CRI_Model(const opto_n_cri::CRI_Environment& env)
  { 
    return new opto_n_cri::Constant_CRI_Model(env);
  }
  
  void
  delete_CRI_Model(opto_n_cri::CRI_Model* cri_model)
  {
    delete cri_model;
  }
  
}
