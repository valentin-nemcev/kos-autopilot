print "Orienting for deorbit burn...".

sas off.

lock steering to retrograde.
wait 1.
wait until steeringManager:angleerror < 1 and ship:angularVel:mag < 0.1.

print "Deorbiting...".
lock throttle to 1.
wait until periapsis < 20000 or stage:liquidfuel < 1.
lock throttle to 0.

wait until altitude < body:atm:height.

print "Entered atmosphere".
stage.
lock steering to srfretrograde.

wait until alt:radar < 10.
print "About to land, releasing control".
