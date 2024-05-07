//start procces
wait until ship:unpacked.
clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

//lunch to orbit
runOncePath ("0:/libs/maneuvers.ks").
runOncePath ("0:/libs/shipControl.ks").

set HeightOrb to 100000.
set maneuverAt to 5000.
set maxTilt to 15.

if ship:status="prelaunch" {
    lunchAt (HeightOrb,maneuverAt,maxTilt).
    circulizingOrb (HeightOrb).
}.


