declare global function calculateSpeedAtPoint {
    parameter pointHeight.
    parameter AP.
    parameter PE.
    local Vpoint to 0.
    set Vpoint to sqrt(ship:body:MU*((2/(pointHeight+ship:body:radius)-(2/(AP+PE+(2*ship:body:radius)))))).
    return Vpoint.
}.

declare global function burnTime {
    parameter executeNode.
    return executeNode:deltav:mag/(ship:maxthrust/ship:mass).
}

declare function calculateFirstTransferHohman {
    parameter Vpoint.
    parameter targetH.
    parameter BodyOrbiting.
    local dV to 0.
    local rad to (targetH+BodyOrbiting:radius)/(BodyOrbiting:radius+ship:apoapsis).
    set dV to Vpoint*(1/(sqrt(rad)))*(1-sqrt(2/((rad)+1))).
    //set dV to Vpoint*(sqrt((2*(rad))/((rad)+1))-1).
    return dV.
}.

declare function calculateSecondTransferHohman {
    parameter Vpoint.
    parameter targetH.
    parameter BodyOrbiting.
    local dV to 0.
    local rad to (targetH+BodyOrbiting:radius)/(BodyOrbiting:radius+ship:apoapsis).
    //set dV to Vpoint*(1/(sqrt(rad)))*(1-sqrt(2/((rad)+1))).
    set dV to Vpoint*(sqrt((2*(rad))/((rad)+1))-1).
    return dV.
}.

