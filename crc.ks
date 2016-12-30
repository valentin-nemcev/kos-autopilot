declare parameter targetApKm is 75.
declare targetAlt to targetApKm * 1000.

function bound {
   parameter lo,val,hi.
   if val < lo return lo.
   if val > hi return hi.
   return val.
}

print "Waiting target altitude of " + targetAlt + "m...".
wait until abs(altitude - targetAlt) < 1000.


print "Circularizing...".

declare step to 0.005.
declare vError to facing:vector.
lock steering to lookdirup(vError, facing:topvector).

declare th to 0.
declare adjTh to 0.

lock throttle to adjTh.

wait step.
until false {
  local engineAccMax to ship:availableThrust / ship:mass.

  local targetVMag is sqrt(body:mu / (body:radius + altitude)).
  local targetVDir is vxcl(up:vector, velocity:orbit):normalized.
  set vError to targetVMag * targetVDir - velocity:orbit.
  set th to bound(0.05, (vError:mag/5) / engineAccMax, 1).
  set adjTh to th * (1 - bound(0, vang(facing:vector, vError)/15, 1)).

  if vError:mag < 0.1 break.
  wait step.
}

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
