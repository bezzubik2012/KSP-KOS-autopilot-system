//staging function
declare global function stagingFunc {
    parameter countStages.
    parameter timeStaging.
    local count to countStages.
    FROM {count.} UNTIL count = 0 STEP {SET count to count - 1.} DO {
        print ("stage "+stage:number+" separating complete").
        stage.
        WAIT timeStaging.
    }
}.

declare global function executeNode {
    parameter exNode.
    parameter startThrottle.
    until exNode:deltav:mag<0.2 {
        if exNode:deltav:mag>=20 {
            lock throttle to startThrottle.
        } else {
            lock throttle to max(exNode:deltav:mag/20,0.1).
        }
    }.
}

declare global function executeNodeRCS {
    parameter exNode.
    until exNode:deltav:mag<0.2 {
        if exNode:deltav:mag>=10 {
            set ship:control:fore to 1.
        } else {
            set ship:control:fore to max(exNode:deltav:mag/10,0.2).
        }
    }.
    set ship:control:neutralize to true.
}

set autoStage to false.

//main rule staging
WHEN MAXTHRUST = 0 THEN {
    if autoStage {
        stagingFunc(1,0.5).
    }
    PRESERVE.
}.
