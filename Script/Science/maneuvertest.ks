declare function calculateDV {
    parameter Vpoint.
    parameter targetH.
    parameter BodyOrbiting.
    local rad to (targetH+BodyOrbiting:radius)/(BodyOrbiting:radius+ship:apoapsis).
    set dV to Vpoint*(1/(sqrt(rad)))*(1-sqrt(2/((rad)+1))).
    //set dV to Vpoint*(sqrt((2*(rad))/((rad)+1))-1).
    return dV.
}.

declare function calculateDVS {
    parameter Vpoint.
    parameter targetH.
    parameter BodyOrbiting.
    local rad to (targetH+BodyOrbiting:radius)/(BodyOrbiting:radius+ship:apoapsis).
    //set dV to Vpoint*(1/(sqrt(rad)))*(1-sqrt(2/((rad)+1))).
    set dV to Vpoint*(sqrt((2*(rad))/((rad)+1))-1).
    return dV.
}.

declare function calculateVAP{
    parameter AltNeed.
    parameter BodyOrbiting.
    parameter AP.
    parameter PE.
    set Vpoint to sqrt(BodyOrbiting:MU*((2/(AltNeed+BodyOrbiting:radius)-(2/(AP+PE+(2*BodyOrbiting:radius)))))).
    return Vpoint.
}.




set VAP to calculateVAP(ship:apoapsis,ship:body,ship:apoapsis,ship:periapsis).

set testNode to node(TimeSpan(ship:obt:eta:apoapsis),0,0,0).
add testNode.
set testNode:prograde to calculateDV(VAP,200000,ship:body).


set testNode2 to node(TimeSpan(testNode2:orbit:eta:apoapsis),0,0,0).
add testNode2.
set testNode2:prograde to calculateDVS(VAP,200000,ship:body).