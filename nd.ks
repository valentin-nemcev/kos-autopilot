list engines in engs.
set isp to engs[0]:isp.
set g0 to 9.82.
// print isp.
// print g0 * isp * ln(ship:mass/(ship:mass - (ship:liquidfuel+ship:oxidizer)*0.005)).

set deltaVFullMag to nextNode:deltaV:mag.

set finalMass to ship:mass * constant:e^(-deltaVFullMag / (isp * g0)).
set burntime to (ship:mass - finalMass) / (ship:availableThrust / (isp * g0)).

print "Burntime: " + round(burntime, 2) + " s".


wait until nextNode:eta < (burntime/2) + 30.

lock steering to nextNode:deltaV.

wait until nextNode:eta < (burntime/2).

lock accTh to min(1, deltaVFullMag/(ship:availableThrust/ship:mass)/2).
lock steeringTh to min(steeringManager:angleError, 5)/5.
lock deltaVTh to nextNode:deltaV:mag/deltaVFullMag * 20.
lock throttle to (1 - steeringTh) * deltavTh * accTh.

wait until nextNode:deltaV:mag < deltaVFullMag * 0.005.

lock throttle to 0.
lock steering to "kill".

wait 1.
