function shipThrust {
  set totalThrust to 0.

  list engines in englist.
  for eng in englist {
      if eng:ignition set totalThrust to totalThrust + eng:thrust.
  }.
  return totalThrust.
}


declare parameter targetApKm is 75.
declare parameter circularize is false.
declare targetAp is targetApKm * 1000.

set ship:control:pilotmainthrottle to 0.
sas off.

from {local cd is 3.} until cd = 0 step {set cd to cd - 1.} do {
    print cd + "...".
    wait 1.
}

lock steering to heading(90, 90).
lock throttle to 1.

when stage:liquidfuel < 0.1 and stage:solidfuel < 0.1 and stage:ready then {
  print "Stage " + stage:number + " complete".
  stage.
  preserve.
}

set launchTS to time.
set initialAbsAngle to body:rotationAngle + ship:geoPosition:lng.
set deltaVSpent to 0.
set deltaVSpentDT to time:seconds.
set integrateDeltaV to true.
on round(time:seconds, 1) {
  set deltaVSpent to deltaVSpent + (shipThrust/ship:mass)*(time:seconds - deltaVSpentDT).
  set deltaVSpentDT to time:seconds.
  return integrateDeltaV.
}

print "Launch!".
stage.

print "Clearing launchpad...".
wait until velocity:surface:mag > 75.

declare targetAlt to 35000.
declare targetPitch to 15.
set targetApM to targetAp * 1.
print "Starting turn...".
lock steering to heading(90, 90 - min(sqrt(altitude / targetAlt), 1) * (90 - targetPitch)).
lock targetPitchErr to vang(up:vector, facing:vector) - vang(up:vector, prograde:vector).
wait until (altitude > targetAlt and targetPitchErr < 1) or apoapsis > targetApM.


set timestep to 0.01.

print "Reaching apoapsis at " + round(targetApM/1000, 2) + "km...".

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

print "Apoapsis at " + round(apoapsis/1000, 2) + "km".


lock throttle to 0.

print "Clearing atmosphere...".

wait until altitude > body:atm:height.
throttlePid:reset().
lock throttle to 1 + throttleError.
print "Adjusting apoapsis...".
until apoapsis > targetAp {
  set throttleError to throttlePid:update(time:seconds, apError).
  wait timestep.
}

lock throttle to 0.

set integrateDeltaV to false.
print "Time since launch " + round((time - launchTS):seconds) + "s".
print "Longtitude offset " + round(body:rotationAngle + ship:geoPosition:lng - initialAbsAngle).
print "Delta V spent " + round(deltaVSpent) + "m/s".
print "Efficiency " + round(velocity:orbit:mag / deltaVSpent, 3).


if circularize {
  run crc(targetApKm).
}
