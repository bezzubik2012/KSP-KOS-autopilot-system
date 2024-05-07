//lunch rocket to target AP
//lunch settings

SET MaxAngleManeuver to 40.
SET StartManeuverALT to 5000.
SET TargetAP to 100000.


CLEARSCREEN.


LOCK THROTTLE TO 1.0.   

//countdown loop
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 0.5.
}

//staging rule

WHEN MAXTHRUST = 0 THEN {
    wait 1.
    PRINT "Staging".
    STAGE.
    PRESERVE.
}.


PRINT "Lunch".

SET MYSTEER TO HEADING(90,0).

wait 5.

PRINT "Heading".

SET MYSTEER TO HEADING(90,90).

LOCK STEERING TO MYSTEER.
UNTIL SHIP:APOAPSIS >= TargetAP { 

    
    IF SHIP:altitude > StartManeuverALT {
        //calculate heading
        set X to log10(SHIP:altitude/StartManeuverALT)*(90-MaxAngleManeuver).

        print ("tilt = "+round (X,2)) at (20,0).

        SET MYSTEER TO HEADING(90,90-X).
    }.

}.

//ap reached, throttle=0
PRINT "AP reached".

LOCK THROTTLE TO 0.

//lock steering to prograde for pass atmoshpere
//lock steering TO prograde.

// wait 70k height
wait until ship:altitude>=70000.

//afterburning for fix possible AP errors
when SHIP:altitude>=70000 then {
    SET MYSTEER TO heading(90,45).
    LOCK steering TO MYSTEER.
    UNTIL ship:apoapsis>=TargetAP {
        print ("afterburn start").
        lock throttle TO 0.5.
        //staging in afterburn procces
        IF maxThrust=0 {
            LOCK throttle TO 0.
            STAGE.
            WAIT 1.
        }.
    }.
    print ("afterburn done").
    LOCK throttle TO 0.
}.



