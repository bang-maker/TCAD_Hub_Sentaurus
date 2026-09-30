/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.
  
  Computation of the temperature dependent absorption coefficient of Si 
  following the paper:
  K. Rajkanan, R. Singh & J. Shewchun, 1979, Solid State Electronics, 22, 793
  
*/

#include "CRIModels.h"
#include <iostream>
#include <stdio.h>
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
		double Eg0[2];
    double Egd0;
    double Ep[2];
    double C_RSS[2];
    double A_RSS[2];
    double Ad;
    double Beta;
    double Gamma;
    double Eg[2];
    double Egd;
		string myName;

  public:
    Constant_CRI_Model(const CRI_Environment& env);
    ~Constant_CRI_Model();
    void Compute_n(double& n);
    void Compute_k(double& k);
  };

  Constant_CRI_Model::Constant_CRI_Model(const CRI_Environment& env) : CRI_Model(env) {
		myName = Name();
#ifdef DEBUG
    cout << "CRI " << myName << ": init\n";
#endif		
    // energy need be in units of eV when things are being computed...
    // Temp T need be in units of K.
		Eg0[0] = InitParameter("Egone0", 1.1557);// eV
		Eg0[1] = InitParameter("Egtwo0", 2.5);// eV
		Egd0 = InitParameter("Egd0", 3.2);// eV
		Ep[0] = InitParameter("Ep1", 0.01827);// eV
		Ep[1] = InitParameter("Ep2", 0.05773);// eV
		C_RSS[0] = InitParameter("C1", 5.5);// 1
		C_RSS[1] = InitParameter("C2", 4.0);// 1
		A_RSS[0] = InitParameter("A1", 3.231e2);// cm^-1eV^-2
		A_RSS[1] = InitParameter("A2", 7.237e3);// cm^-1eV^-2
		Ad = InitParameter("Ad", 1.052e6);// cm^-1eV^-2
		Beta = InitParameter("Beta", 7.021e-04);// eV/K
		Gamma = InitParameter("Gamma", 1108);// K
		//#ifdef DEBUG
		cout <<"============================================================\n";
		printf("CRI model %s for Silicon (region: %s material: %s)\n", myName.c_str(),  ReadRegionName().c_str(), ReadMaterialName().c_str());
		cout <<"============================================================\n";
		printf("%-6s:% 11.4g || %-6s:% 11.4g || %-4s:% 11.4g\n", "Egone0", Eg0[0], "Egtwo0", Eg0[1], "Egd0", Egd0);
		printf("%-6s:% 11.4g || %-6s:% 11.4g ||\n", "Ep1", Ep[0], "Ep2 ", Ep[1]);
		printf("%-6s:% 11.4g || %-6s:% 11.4g ||\n", "C1", C_RSS[0], "C2 ", C_RSS[1]);
		printf("%-6s:% 11.4g || %-6s:% 11.4g || %-4s:% 11.4g\n", "A1", A_RSS[0], "A2 ", A_RSS[1], "Ad", Ad);
		printf("%-6s:% 11.4g || %-6s:% 11.4g ||\n", "Beta", Beta, "Gamma", Gamma);								 
		//#endif
  }

  Constant_CRI_Model::~Constant_CRI_Model() {
#ifdef DEBUG
    cout << "CRI_Model: delete\n";
#endif
  }

  void Constant_CRI_Model::Compute_n(double& n) {
#ifdef DEBUG
    printf("CRI %s: Wavelength = %.4g um\n", myName.c_str(), ReadWavelength());
#endif
		n = Read_n();
#ifdef DEBUG
		printf("CRI %s: n = %.4g\n", myName.c_str(), n); 
#endif
  }
	
  void Constant_CRI_Model::Compute_k(double& k) {
    double Alpha_v = 0;// cm^-1
    double Alpha_d = 0;// cm^-1
		double T = ReadTemperature(); // K
		double PhotonE = BoltzmannConstant*SpeedOfLight/(1e-6*ReadWavelength())/ElectronCharge; // eV
#ifdef DEBUG
		printf("CRI %s: T = %.4g K Wavelength = %.4g um PhotonE = %.4g eV\n", myName.c_str(), T, ReadWavelength(), PhotonE); 
#endif
    Eg[0] =  Eg0[0] - Beta*T*T/(T+Gamma);
    Eg[1] =  Eg0[1] - Beta*T*T/(T+Gamma);
    Egd = Egd0  - Beta*T*T/(T+Gamma);
    for(int i = 0; i < 2; i ++) {
			for(int j = 0; j < 2; j ++) {
				double Term1 = 0;
				double Term2 = 0;
				if ((Eg[j] - Ep[i]) < PhotonE) 
					Term1 = (PhotonE - Eg[j] + Ep[i])*(PhotonE - Eg[j] + Ep[i]);
				if  ((Eg[j] + Ep[i]) <= PhotonE) 
					Term2 = (PhotonE - Eg[j] - Ep[i])*(PhotonE - Eg[j] - Ep[i]);
				Alpha_v += C_RSS[i]*A_RSS[j]*(Term1/(exp(Ep[i]/kq/T)-1) + Term2/(1-exp(-Ep[i]/kq/T)));// cm^-1
			}
		}
    if(PhotonE > Egd) {
			Alpha_d = Ad*sqrt((PhotonE - Egd)); 
		}
		double Alpha = (Alpha_d + Alpha_v); // cm^-1
    k = Alpha/1.e-2*(ReadWavelength()*1.e-6)/4./Pi; // [1]
#ifdef DEBUG
		printf("CRI %s: k = %.4g alpha: %.4g cm^-1\n", myName.c_str(), k, Alpha); 
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
