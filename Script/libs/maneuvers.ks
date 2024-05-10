runOncePath ("0:/libs/calculations.ks").
runOncePath ("0:/libs/shipControl.ks").

declare global function lunchAt {
    parameter targetHeight.
    parameter startingManAt.
    parameter maxAngle.

    print ("lunch at height initialized").

    //prelunch procces
    local mySteer to heading(90,0).
    lock throttle TO 1.0.
    lock steering to mySteer.

    //countdown loop
    print "Counting down:".
    from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
        print "..." + countdown.
        wait 1.
    }
    
    //lunch
    set autoStage to true.
    print "Lunch".
    wait 5.
    print "Heading".
    set mySteer to heading(90,90).

    until ship:apoapsis >= targetHeight {
        IF ship:altitude > startingManAt {
            //calculate heading
            local X to 0.
            set X to log10(ship:altitude/startingManAt)*(90-maxAngle).
            print ("tilt = "+round (X,2)) at (30,0).
            set mySteer to heading(90,90-X).
            }.
        }.
        //ap reached, throttle=0
        print ("AP reached").
        lock THROTTLE to 0.
        lock steering to prograde.
        print ("target AP = "+targetHeight).
        print ("achived AP = "+ship:apoapsis).
        print ("error = "+(targetHeight-ship:apoapsis)).

        print ("waiting 70000m altitude").
        wait until ship:altitude>=70000.
    }.

declare global function circulizingOrb {
    parameter targetHeight.
    parameter patchingNeeded.

    local speedAtAP to 0.
    local speedAtOrb to 0.
    local dV to 0.
    local CircNode to node(0,0,0,0).
    local Btime to 0.
    //preprocess
    clearScreen.
    print("circulizing orbit initialized").
    sas off.
    print ("SAS OFF").
    rcs on.
    print ("RCS ON").
    print ("orbit around:" +ship:body).

    //create maneuver node
    set CircNode to node(time:seconds+ship:obt:eta:apoapsis,0,0,0).
    add CircNode.

    //calculate dV
    set speedAtAP to calculateSpeedAtPoint(ship:apoapsis,ship:apoapsis,ship:periapsis).
    set speedAtOrb to calculateSpeedAtPoint(ship:apoapsis,ship:apoapsis,targetHeight).
    set dV to SpeedAtOrb-SpeedAtAP.
    set CircNode:prograde to dV.

    print ("speed at AP = "+SpeedAtAP).
    print ("speed at OrB = "+SpeedAtOrb).
    print ("dV needed = "+dV).

    //calculate burn time
    set Btime to burnTime(CircNode).
    lock steering to CircNode:deltav.

    print ("orbit circulized maneuver calculation done").
    print ("AP = "+CircNode:orbit:apoapsis).
    print ("PE = "+CircNode:orbit:periapsis).
    print ("error = "+(CircNode:orbit:apoapsis-CircNode:orbit:periapsis)).
    print ("Burn time = "+Btime).

    //wait until burn time
    print ("waiting maneuver").
    wait until CircNode:eta<=(Btime/2).
    
    print ("star circulizing").
    executeNode (CircNode,1).

    //end circulizing
    lock throttle to 0.
    lock steering to prograde.
    remove CircNode.

    print ("circulizing done").
    print ("achived AP = "+ship:apoapsis).
    print ("achived PE = "+ship:periapsis).
    print ("error at AP = " +(ship:apoapsis-targetHeight)).
    print ("error at PE = " +(ship:periapsis-targetHeight)).

    if patchingNeeded {
        patchOrbit(targetHeight,2000).
    }.
}.

declare global function patchOrbit {
    parameter targetHeight.
    parameter err.
    local speedAtAP to 0.
    local speedAtPE to 0.
    local speedAPTarget to 0.
    local speedPETarget to 0.
    local dV to 0.
    local manNode to node(0,0,0,0).
    local bTime to 0.

    //preprocess
    clearScreen.
    print ("patch orbit procces initializing").
    rcs on.
    sas off.
    print ("RCS ON").
    print ("SAS OFF").

    //calculate AP dV
    local APerr to ship:apoapsis-targetHeight.
    local PEerr to ship:apoapsis-targetHeight.

    until abs(APerr<=err) and abs(PEerr<=err) {
        if (ship:obt:eta:apoapsis+time:seconds)>(ship:obt:eta:periapsis+time:seconds) {
            if abs(APerr)>err {
                //patch AP process
                print ("AP patching process start").

                set speedAtAP to calculateSpeedAtPoint(ship:periapsis,ship:apoapsis,ship:periapsis).
                set speedAPTarget to calculateSpeedAtPoint(ship:periapsis,targetHeight,ship:periapsis).
                set dV to speedAPTarget-speedAtAP.

                print ("speed at AP = "+speedAtAP).
                print ("target speed at AP = "+speedAPTarget).
                print ("dV needed = "+dV).

                set manNode to node(time:seconds+ship:obt:eta:periapsis,0,0,dV).
                add manNode.

                print ("target AP = "+manNode:obt:apoapsis).
                print ("error = "+(manNode:obt:apoapsis-targetHeight)).

                lock steering to manNode:deltav.
                set bTime to burnTime(manNode).
                print ("burn time = "+bTime).

                print("waiting maneuver").
                if manNode:deltav:mag<20 {
                    wait until manNode:eta<=(bTime/2).
                    executeNodeRCS(manNode).
                } else {
                    wait until manNode:eta<=(bTime/2).
                    executeNode(manNode,1).
                }
                
                lock steering to prograde.
               // remove nextNode.

                print("waiting AP").
                wait (ship:obt:eta:apoapsis+time:seconds)<(ship:obt:eta:periapsis+time:seconds).
            } else {
                print ("AP patch not needed").
                print("waiting AP").
                wait (ship:obt:eta:apoapsis+time:seconds)<(ship:obt:eta:periapsis+time:seconds).
            }.
        } else {
            if abs(PEerr)>err {
                //patch PE process
                print ("PE patching process start").

                set speedAtPE to calculateSpeedAtPoint(ship:apoapsis,ship:apoapsis,ship:periapsis).
                set speedPETarget to calculateSpeedAtPoint(ship:apoapsis,ship:apoapsis,targetHeight).
                set dV to speedPETarget-speedAtPE.

                print ("speed at PE = "+speedAtPE).
                print ("target speed at PE = "+speedPETarget).
                print ("dV needed = "+dV).

                set manNode to node(time:seconds+ship:obt:eta:apoapsis,0,0,dV).
                add manNode.

                print ("target PE = "+manNode:obt:periapsis).
                print ("error = "+(manNode:obt:periapsis-targetHeight)).

                lock steering to manNode:deltav.
                set bTime to burnTime(manNode).
                print ("burn time = "+bTime).

                print("waiting maneuver").
                if manNode:deltav:mag<20 {
                    wait until manNode:eta<=(bTime/2).
                    executeNodeRCS(manNode).
                } else {
                    wait until manNode:eta<=(bTime/2).
                    executeNode(manNode,1).
                }
                lock steering to prograde.
                remove nextNode.

                print("waiting PE").
                wait until (ship:obt:eta:apoapsis+time:seconds)>(ship:obt:eta:periapsis+time:seconds).
            } else {
                print ("PE patch not needed").
                print("waiting PE").
                wait (ship:obt:eta:apoapsis+time:seconds)>(ship:obt:eta:periapsis+time:seconds).
            }.
        }
    }.
    print ("patch orbit complete").

}.

declare global function hohmannTransfer {
    parameter targetOrb.
    parameter pathcing.

    print ("Initialized Hohmann transfer to orbit "+targetOrb).

    local VAP to calculateSpeedAtPoint (ship:apoapsis,ship:apoapsis,ship:periapsis).

    set firstMan to node(TimeSpan(ship:obt:eta:apoapsis),0,0,0).
    add firstMan.
    set firstMan:prograde to calculateFirstTransferHohman(VAP,200000,ship:body).

    local bTime1 to burnTime(firstMan).

    set secondMan to node(TimeSpan(firstMan:orbit:eta:apoapsis),0,0,0).
    add secondMan.
    set secondMan:prograde to calculateSecondTransferHohman(VAP,200000,ship:body).

    local bTime2 to burnTime(secondMan).

    lock steering to firstMan:deltav.

    wait until firstMan:eta<=(bTime1/2).
    executeNode(nextNode,1).
   
    remove firstMan.
    lock steering to nextNode:deltav.

    wait until nextNode:eta<=(bTime2/2).
    executeNode(nextNode,1).

    if pathcing {
        patchOrbit(targetOrb,2000).
    }.
}.