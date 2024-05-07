//circulizing orbit 
clearScreen.
print ("take conrtrol").
sas off.
print ("SAS OFF").
rcs on.
print ("RCS ON").

//lock steering TO prograde.

print ("time to AP: "+ship:obt:eta:apoapsis).


//add node
set CircNode to node(TimeSpan(ship:obt:eta:apoapsis),0,0,0).
add CircNode.

print (ship:body).

//calculate speed
set SpeedAP to calculateSpeedAtPoint(ship:apoapsis,ship:body,ship:apoapsis,ship:periapsis).
set SpeedOrb to calculateSpeedAtPoint(ship:apoapsis,ship:body,ship:apoapsis,ship:apoapsis).
set dVneed to SpeedOrb-SpeedAP.
set CircNode:prograde to dVneed.

print ("speed at AP = "+SpeedAP).
print ("speed at OrB = "+SpeedOrb).
print ("dV needed = "+dVneed).

//calculate burn time
set Btime to CircNode:deltav:mag/(ship:maxthrust/ship:mass).
lock steering to CircNode:deltav.

print ("orbit circulized maneuver calculation done").
print ("AP = "+CircNode:orbit:apoapsis).
print ("PE = "+CircNode:orbit:periapsis).
print ("error = "+(CircNode:orbit:apoapsis-CircNode:orbit:periapsis)).
print ("Burn time = "+Btime).



print ("waiting maneuver").
wait until CircNode:eta<=((Btime/2)+1).

print ("star circulizing").
until CircNode:deltav:mag<0.2 {
    if CircNode:deltav:mag>=20 {
        lock throttle to 1.
    } else {
        lock throttle to max(CircNode:deltav:mag/20,0.1).
    }
    
}
print ("circulizing done").
lock throttle to 0.
lock steering to prograde.
remove CircNode.

declare function calculateSpeedAtPoint {
    parameter AltNeed.
    parameter BodyOrbiting.
    parameter AP.
    parameter PE.
    set Vpoint to sqrt(BodyOrbiting:MU*((2/(AltNeed+BodyOrbiting:radius)-(2/(AP+PE+(2*BodyOrbiting:radius)))))).
    return Vpoint.
}.


