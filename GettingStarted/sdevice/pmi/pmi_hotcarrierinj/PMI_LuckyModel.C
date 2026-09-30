/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <stdlib.h>
#include <math.h>

#include "PMIModels.h"

class PMI_LuckyModel : public PMI_HotCarrierInjection {
private:
  const des_mesh* mesh;  //device mesh
  des_data* data;  //device data
  const double*const* measure;
  const double*const* surface_measure;
public:
  PMI_LuckyModel(const PMI_Device_Environment& env, const PMI_CarrierType carType);
  ~PMI_LuckyModel();
  void Compute_gCurr(const des_regioninterface_vector& regioninterfaces,
    des_array_vector& gCurr);
};

//////////////////////////////////////////////////////////////////////
PMI_LuckyModel::PMI_LuckyModel(const PMI_Device_Environment& env, const PMI_CarrierType carType) :
PMI_HotCarrierInjection(env, carType)
{
  mesh = Mesh();
  data = Data();
  measure = data->ReadMeasure();
  surface_measure = data->ReadSurfaceMeasure();
}

PMI_LuckyModel::~PMI_LuckyModel()
{ }
void PMI_LuckyModel::Compute_gCurr(const des_regioninterface_vector& regioninterfaces,
  des_array_vector& gCurr)
{
  //compute current for each des_regioninterface associated with
  //model
  for(int inter=0; inter < regioninterfaces.size(); inter++) {
    for(int k=0; k < regioninterfaces.at(inter)->size_vertex(); k++)
      gCurr[inter][k] = 0.0;
    
    des_regioninterface* ri = regioninterfaces.at(inter);
    des_bulk* b1 = ri->bulk1();
    des_bulk* b2 = ri->bulk2();
    
    //recognize regioninterface or regioninterface category
    if(((b1->material() == "Silicon") && (b2->material() == "Oxide")) ||
      ((b1->material() == "Oxide") && (b2->material() == "Silicon"))) {
    
    des_bulk* semReg;
    des_bulk* insReg;
    if((b1->material() == "Silicon") && (b2->material() == "Oxide")) {
      semReg = b1;
      insReg = b2;
    }
    if((b2->material() == "Silicon") && (b1->material() == "Oxide")) {
      semReg = b2;
      insReg = b1;
    }
    
    ///////////////////////////////////////////////////////////////////////
    //model implementation
    
    //LuckyModel
    //{ * Ig = J*p1*p2*p3/eLsemR - Electron gate current density,
    //*      p1 = 0.25*(Eeff*eLsem/B)*exp (-B/Eeff/eLsem),
    //*           B = eBar0-eBL12*Eox^1/2-eBL23*Eox^2/3+Vox,
    //*      p2 = exp (-y/eLsem),
    //*      p3 = exp (-x0/eLins),
    //* where eBar0 is zero field Barrier height for electrons,
    //*       eBL12 is Barrier Lowering coefficient due to the image potetial,
    //*       eBL23 is Barrier Lowering coefficient due to the tunneling,
    //*       eLsem is the mean free path in semiconductor,
    //*       eLsemR is the redirection mean free path in semiconductor,
    //*       eLins is the mean free path in insulator.
    //eBar0 = 3.1   # [eV]
    //eBL12 = 2.6000e-04    # [(V*cm)^1/2]
    //eBL23 = 3.0000e-05    # [(V*cm^2)^1/3]
    //eLsem = 8.9000e-07    # [cm]
    //eLsemR        = 6.2000e-06    # [cm]
    //eLins = 3.2000e-07    # [cm]
    //* the same for holes
    //hBar0 = 4.7   # [eV]
    //hBL12 = 2.6000e-04    # [(V*cm)^1/2]
    //hBL23 = 3.0000e-05    # [(V*cm^2)^1/3]
    //hLsem = 1.0000e-07    # [cm]
    //hLsemR        = 6.2000e-06    # [cm]
    //hLins = 3.2000e-07    # [cm]
    //* See the manual for more details.
    //}
    
    //read region interface constants
    double eLambd = 8.9000e-07;//eLsem
    double eLambdR = 6.2000e-06;//eLsemR
    double eOxLambd = 3.2000e-07;//eLins
    double eBarrierHeight = 3.1;//eBar0
    double eAlfa = 2.6000e-04;//eBL12
    double eBeta = 3.0000e-05;//eBL23
    
    double hLambd = 1.0000e-07;//hLsem
    double hLambdR = 6.2000e-06;//hLsemR
    double hOxLambd = 3.2000e-07;//hLins
    double hBarrierHeight = 4.7;//hBar0
    double hAlfa = 2.6000e-04;//hBL12
    double hBeta = 3.0000e-05;//hBL23
    
    //read DataEntries used in computation
    const double* pot =
    data->ReadScalar(des_data::vertex, "ElectrostaticPotential");
    const double* OxField =
    data->ReadScalar(des_data::vertex,"InsulatorElectricField");
    const double* Epsilon =
    data->ReadScalar(des_data::element, "DielectricConstant");
    const double* eCurrent = NULL;
    const double* eField = NULL;
    const double* hCurrent = NULL;
    const double* hField = NULL;
    if(cType == PMI_Electron) {
      eCurrent = data->ReadScalar(des_data::vertex, "eCurrentDensity");
      eField = data->ReadScalar(des_data::vertex,"eEparallel");
    }
    else if(cType == PMI_Hole) {
      hCurrent = data->ReadScalar(des_data::vertex, "hCurrentDensity");
      hField = data->ReadScalar(des_data::vertex,"eEparallel");
    }
    
    //integrate over the corresponding semiconductor region
    for(size_t vi = 0; vi < semReg->size_vertex(); vi++) {
      des_vertex* rv = semReg->vertex(vi);
      
      //find the nearest interface vertex
      //(distance to interface)
      des_vertex* NearestInterVertex;
      int NearestInterVertexRIind;
      double NearestDistance = 1.0e50;
      for(size_t k=0; k < ri->size_vertex(); k++) {
        des_vertex* interVert = ri->vertex(k);
        bool isSemiconductor = false;
        for(size_t i = 0; i < interVert->size_region(); i++) {
          des_bulk* b = dynamic_cast<des_bulk*>(interVert->region(i));
          if(b->material() == "Silicon") {
            isSemiconductor = true;
          }
        }
        if(isSemiconductor) {
          double dist = 0.0;
          for(int kk=0; kk < mesh->dim(); kk++)
            dist += (interVert->coord()[kk] - rv->coord()[kk])*
          (interVert->coord()[kk] - rv->coord()[kk]);
          dist = sqrt(dist);
          if(dist < NearestDistance) {
            NearestDistance = dist;
            NearestInterVertex = interVert;
            NearestInterVertexRIind = k;
          }
        }
      }//nearest interface vertex
      
      //find the nearest gate contact vertex
      //(distance from NearestIntVertex to gate contact)
      des_vertex* NearestContVertex;
      double NearestContDistance = 1.0e50;
      for(size_t k=0; k < insReg->size_vertex(); k++) {
        des_vertex* vins = insReg->vertex(k);
        if(vins->size_region() > 1) {
          for(size_t vvr = 0; vvr < vins->size_region(); vvr++) {
            des_region* rr = vins->region(vvr);
            if(rr->type() == des_region::contact) {
              //contact vertex
              double dist = 0.0;
              for(int kk=0; kk < mesh->dim(); kk++)
                dist += (vins->coord()[kk] - NearestInterVertex->coord()[kk])*
              (vins->coord()[kk] - NearestInterVertex->coord()[kk]);
              dist = sqrt(dist);
              if(dist < NearestContDistance) {
                NearestContDistance = dist;
                NearestContVertex = vins;
              }
            }//contact vertex
          }
        }
      }//nearest gate contact vertex
      
      //coordinates and distances are in um
      //transform to cm
      double OxThickn = NearestContDistance*1.0e-4;
      double DistToSurf = NearestDistance*1.0e-4;
      
      double xEps[3] = {0.0, 0.0, 0.0};
      for(int k = 0; k < mesh->dim(); k++)
      xEps[k] = 0.5*(NearestInterVertex->coord()[k]
        + NearestContVertex->coord()[k]);
      des_element* xEl;
      //find the oxide element
      for(size_t ei = 0; ei < insReg->size_element(); ei++) {
        des_element* e = insReg->element(ei);
        for(size_t evi = 0; evi < e->size_vertex(); evi++) {
          double minCoord[3] = {1.0e50, 1.0e50, 1.0e50};
          double maxCoord[3] = {-1.0e50, -1.0e50, -1.0e50};
          des_vertex* ev = e->vertex(evi);
          for(int i = 0; i < mesh->dim(); i++) {
            if(ev->coord()[i] < minCoord[i])
              minCoord[i] = ev->coord()[i];
            if(ev->coord()[i] > maxCoord[i])
              maxCoord[i] = ev->coord()[i];
          }
          for(int i = 0; i < mesh->dim(); i++) {
            if( (xEps[i] >= minCoord[i]) && (xEps[i] >= minCoord[i]) ) {
              xEl = e;
            }
          }
        }
      }
      double OxConst = Epsilon[xEl->index()];
      double OxImage0 = 1.6e-19/16/3.1452/8.85e-14/OxConst;
      
      //for electrons
      if(cType == PMI_Electron) {
        double eCur = 0.0;
        
        double eOxField = pot[NearestContVertex->index()]
        -pot[NearestInterVertex->index()];
        eOxField = eOxField > 0
        ? OxField[NearestInterVertex->index()]
        : -OxField[NearestInterVertex->index()];
        
        double barrier;
        if(pot[NearestInterVertex->index()] < pot[NearestContVertex->index()])
          barrier = eBarrierHeight
        - eAlfa*sqrt(fabs(eOxField))
        - eBeta*pow(fabs(eOxField),2.0/3.0);
        else
          barrier = eBarrierHeight
        + (pot[NearestInterVertex->index()] -
          pot[NearestContVertex->index()])
        - eAlfa*sqrt(fabs(eOxField))
        - eBeta*pow(fabs(eOxField),2.0/3.0);
        if(barrier < 0) barrier = 0.0;
        double eBarrierLoc = barrier;
        
        double p1 = 0.0;
        double eEnergy = eField[rv->index()]*eLambd;
        
        if(eEnergy > 1.0e-30) {
          p1 = 0.25;
          if (eBarrierLoc > 1.0e-30)
            p1 = 0.25*eEnergy/eBarrierLoc*exp(-eBarrierLoc/eEnergy);
        }
        
        double p2 = exp(-DistToSurf/eLambd);
        
        double eDistFromSurf = 1.0e30;
        if (eOxField > 1.0e-30) eDistFromSurf = sqrt(OxImage0/eOxField);
        double p3 = exp(-eDistFromSurf/eOxLambd);
        
        //find the node measure
        double node_measure = 0.0;
        for(size_t ei = 0; ei < rv->size_element(); ei++) {
          des_element* e = rv->element(ei);
          des_bulk* bulk = e->bulk();
          if(bulk->material() == "Silicon") {
            for(size_t evi = 0; evi < e->size_vertex(); evi++) {
              des_vertex* ev = e->vertex(evi);
              if(ev->index() == rv->index()) {
                node_measure += measure[e->index()][evi];
              }
            }
          }//semiconductor element
        }//node measure
        //convert measure in cm^dim
        node_measure = node_measure*pow(1.0e-4,mesh->dim());
        
        eCur = eCurrent[rv->index()]*p1*p2*p3*node_measure/eLambdR;
        
        double risurface = surface_measure[ri->index()][NearestInterVertexRIind];
        //convert to cm^(dim-1)
        risurface = risurface*pow(1.0e-4,(mesh->dim()-1));
        gCurr[inter][NearestInterVertexRIind] += eCur/risurface;
      }
      
      //for holes
      if(cType == PMI_Hole) {
      }
    }//end integration on semiconductor region
    
    //end model implementation
    /////////////////////////////////////////////////////////////////////
      }
  }//end loop over regioninterfaces associated with "PMI_HotCarrierInjection" model
}

/////////////////////////////////////////////////////////////////////

extern "C" {
  PMI_HotCarrierInjection* new_PMI_e_HotCarrierInjection
  (const PMI_Device_Environment& env, const PMI_CarrierType carType)
  {
    return new PMI_LuckyModel(env, carType);
  }
}

extern "C" {
  PMI_HotCarrierInjection* new_PMI_h_HotCarrierInjection
  (const PMI_Device_Environment& env, const PMI_CarrierType carType)
  {
    return new PMI_LuckyModel(env, carType);
  }
}
