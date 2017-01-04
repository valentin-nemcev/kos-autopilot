runOncePath("lib_misc").
runOncePath("lib_control").
runOncePath("lib_deltav").

parameter targetApKm is 75.
parameter circularize is false.
parameter launchAz to 90.
global targetAp is targetApKm * 1000.

set ship:control:pilotmainthrottle to 0.
sas off.

lock steering to heading(launchAz, 90).
lock throttle to 1.

when stage:liquidfuel < 0.1 and stage:solidfuel < 0.1 and stage:ready then {
  print "Stage " + stage:number + " complete".
  deltaV_print().
  stage.
  preserve.
}

set launchTS to time.
set initialAbsAngle to body:rotationAngle + ship:geoPosition:lng.


deltaV_start().
on round(time:seconds, 1) {
  deltaV_update().
  return deltaV_integrate.
}


print "Launch!".
stage.

print "Clearing launchpad...".
wait until altitude > 100.

global targetAlt to 35000.
global targetPitch to 10.
set targetApM to targetAp * 1.01.
print "Starting turn...".

lock steering to heading(launchAz, 90 - min(sqrt(altitude / targetAlt), 1) * (90 - targetPitch)).
lock targetPitchErr to vang(up:vector, facing:vector) - vang(up:vector, prograde:vector).


global apDelay to 45.
function apError {
  if obt:trueAnomaly < 180 return eta:apoapsis - apDelay.
  return 0.
}

set throttlePid to pidloop(1/apDelay, 0, 1/2).
set throttlePid:maxOutput to 0.
set throttlePid:minOutput to -0.75.

lock throttle to 1 + throttlePid:update(time:seconds, apError()).

wait until (altitude > targetAlt and targetPitchErr < 1) or apoapsis > targetApM.

lock steering to heading(launchAz, max(0, 90 - vang(up:vector, prograde:vector))).

print "Reaching apoapsis at " + round(targetApM/1000, 2) + "km...".
wait until apoapsis > targetApM.

print "Apoapsis at " + round(apoapsis/1000, 2) + "km".

lock throttle to 0.
deltaV_print().

print "Clearing atmosphere...".
wait until altitude > body:atm:height.

if (apoapsis < targetAp) {
  print "Adjusting apoapsis...".
  throttlePid:reset().
  lock throttle to 1 + throttlePid:update(time:seconds, apError()).

  wait until apoapsis > targetAp.

  lock throttle to 0.
  deltaV_stop().
}

deltaV_print().
print "Time since launch " + round((time - launchTS):seconds) + "s".
print "Longtitude offset " + round(body:rotationAngle + ship:geoPosition:lng - initialAbsAngle).

if circularize {
  run crc(targetApKm).
}
