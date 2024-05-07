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

