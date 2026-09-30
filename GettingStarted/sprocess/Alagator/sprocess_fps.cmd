line x location= 0.0<um> spacing= 1.0<nm> tag= top
line x location= 0.5<um> spacing= 5.0<nm>
line x location= 10.0<um> spacing= 5.0<nm> tag= bottom
region Silicon xlo= top xhi= bottom
init

select z= "2.0e18 * exp(-(x-0.5)*(x-0.5) / (0.03 * 0.03)) + 1.0e10" \
	name= M store 
select z= 1e5 name= M2 store
SetPlxList { M M2 }
WritePlx  n@node@_Minitial.plx

solution name= M  add !negative !damp ifpresent = "M"
solution name= M2 add !negative !damp ifpresent = "M2 M"

struct tdr= n@node@_Minitial

# Version 1: Direct definition
# ----------------------------

set D0 "\[Arrhenius 1e-4 1.5\]"
set k1 "4 * 3.1415 * 2.7e-8 * $D0"
set k2 "\[Arrhenius 5.0e22 3.0\]"

pdbSetString Silicon M Equation "ddt(M)-$D0*grad(M)+2*$k1*(M^2-$k2*M2)" 

pdbSetString Silicon M2 Equation "ddt(M2)-$k1*(M^2-$k2*M2)" 

diffuse info= 2 temperature= 800.00<C> time= 20<s> init= 1.e-08<s>
WritePlx  n@node@_Mfinal_V1.plx

# Version 2: Using terms
# ----------------------

init tdr= n@node@_Minitial

set D0 "\[Arrhenius 1e-4 1.5\]"
set k1 "4 * 3.1415 * 2.7e-8 * $D0"
set k2 "\[Arrhenius 5.0e22 3.0\]"

term name= MReact Silicon add eqn= "$k1 * ( M^2 - $k2 * M2)"

pdbSetString Silicon M  Equation "ddt(M) - $D0 * grad(M) + 2 * MReact"
pdbSetString Silicon M2 Equation "ddt(M2) -  MReact"

diffuse info= 2 temperature= 800.00<C> time= 20<s> init= 1.e-08<s>
WritePlx  n@node@_Mfinal_V2.plx

# Version 3: Using callback
# -------------------------

init tdr= n@node@_Minitial

pdbSetString Silicon  M EquationProc MEquation 

pdbSetDouble Silicon  M D0 "\[Arrhenius 1e-4 1.5\]"
pdbSetDouble Silicon  M k1 "4*3.1415*2.7e-8*\[pdbDelayDouble Silicon M D0\]"
pdbSetDouble Silicon  M M2 k2 "\[Arrhenius 5.0e22 3.0\]"
pdbSetString Silicon  M React "M2"

proc MEquation { Material Solution } {
    
    set D0    [pdbDelayDouble $Material $Solution D0]
    set k1    [pdbDelayDouble $Material $Solution k1]
    set React [pdbGetString $Material $Solution React]
    set k2    [pdbDelayDouble $Material $Solution $React k2]
    
    term name= ${Solution}React $Material add \
         eqn= "$k1 * ( $Solution^2 - $k2 * $React)"
    
    pdbSetString $Material $Solution  Equation \
      "ddt($Solution) - $D0 * grad($Solution) + 2 * ${Solution}React"

    pdbSetString $Material $React Equation \
      "ddt($React) -  ${Solution}React"
}

diffuse info= 2 temperature= 800.00<C> time= 20<s> init= 1.e-08<s>
WritePlx  n@node@_Mfinal_V3.plx

exit

