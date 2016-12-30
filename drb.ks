
sas off.
set targetPeriapsis to 20000.

if periapsis > targetPeriapsis {
  print "Orienting for deorbit burn...".

  lock steering to retrograde.
  wait 1.
  wait until steeringManager:angleerror < 1 and ship:angularVel:mag < 0.1.

  print "Deorbiting...".
  lock throttle to 1.
  wait until periapsis < targetPeriapsis or ship:liquidfuel < 1.
  lock throttle to 0.
}

print "Descending...".

wait until altitude < body:atm:height.

print "Entered atmosphere".
stage.
lock steering to srfretrograde.

wait until velocity:surface:mag < 10.
print "About to land, releasing control".
