runOncePath("lib_orbit").

sas off.
set targetPeriapsis to 20000.

if periapsis > targetPeriapsis {
  print "Orienting for deorbit burn...".

  lock steering to lookDirUp(retrograde:vector, ship:facing:topVector).
  wait 1.
  wait until steeringManager:angleerror < 1 and ship:angularVel:mag < 0.1.

  print "Deorbiting...".
  lock throttle to 1.
  wait until periapsis < targetPeriapsis or stage:liquidfuel < 0.1.
  lock throttle to 0.
}

print "Descending...".

local targetTAn to trueAnFromHalfTrueAn(
  halfTrueAnomalyAtAlt(obt, body:atm:height),
  obt:trueAnomaly
 ).
local etaToTarget to deltaTimeBetweenEAn(
  obt,
  eccentricAnFromTrueAn(obt, obt:trueAnomaly),
  eccentricAnFromTrueAn(obt, targetTAn)
 ).


print "Warping to +" +  (time - time:seconds + etaToTarget):clock.
wait 3.
kUniverse:timeWarp:warpTo(time:seconds + etaToTarget).

wait until altitude < body:atm:height.

print "Entered atmosphere".

lock steering to srfretrograde.

wait 5.
lock throttle to 1.
wait until stage:liquidfuel < 0.1 or altitude < 40000.
lock throttle to 0.
stage.
chutes on.
wait until altitude < 10000.
print "About to land, releasing control".
