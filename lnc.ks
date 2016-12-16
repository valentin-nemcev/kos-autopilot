declare parameter targetApKm is 75.
declare parameter circularize is false.
declare targetAp is targetApKm * 1000.

from {local cd is 3.} until cd = 0 step {set cd to cd - 1.} do {
    print cd + "...".
    wait 1.
}

lock steering to heading(90, 90).
lock throttle to 1.

when stage:liquidfuel < 0.1 and stage:solidfuel < 0.1 and stage:ready then { stage. preserve. }

print "Launch!".
stage.

print "Clearing launchpad...".
wait until velocity:surface:mag > 75.

declare targetAlt to 35000.
declare targetPitch to 15.
print "Starting turn...".
lock steering to heading(90, 90 - min(sqrt(altitude / targetAlt), 1) * (90 - targetPitch)).
wait until altitude > targetAlt and vang(up:vector, facing:vector) > vang(up:vector, prograde:vector).


print "Reaching apoapsis at " + targetAp + "m...".

set targetApM to targetAp * 1.025.
set timestep to 0.01.

// lock apError to apoapsis - targetApM.
// set throttlePid to pidloop(1/(0.5 * targetAp), 0, (1/(0.00025 * targetAp)) * timestep).
// set throttlePid:maxOutput to 0.
// set throttlePid:minOutput to -0.75.

lock apError to (180 - 7.5) - obt:trueAnomaly.
set throttlePid to pidloop(1/7.5).
set throttlePid:maxOutput to 0.
set throttlePid:minOutput to -0.75.


lock steering to prograde.

declare throttleError to 0.
lock throttle to 1 + throttleError.

until apoapsis > targetApM {
  set throttleError to throttlePid:update(time:seconds, apError).
  wait timestep.
}

set ship:control:pilotmainthrottle to 0.
lock throttle to 0.

print "Clearing atmosphere...".

wait until altitude > body:atm:height.
lock throttle to 1 + throttleError.
print "Adjusting apoapsis...".
until apoapsis > targetAp {
  set throttleError to throttlePid:update(time:seconds, apError).
  wait timestep.
}

lock throttle to 0.

if circularize {
  run crc(targetApKm).
}
