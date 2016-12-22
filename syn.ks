function vectorProjection {
  parameter a.
  parameter b.
  return ((a * b) / (b * b)) * b.
}

function scalarProjection {
  parameter a.
  parameter b.
  return (a * b) / b:mag.
}

lock relTargetPosition to target:obt:position - ship:obt:position.
lock relTargetVelocity to ship:obt:velocity:orbit - target:obt:velocity:orbit.
lock velocityToTarget to vectorProjection(relTargetVelocity, relTargetPosition).
lock velocityToTargetMag to scalarProjection(relTargetVelocity, relTargetPosition).
lock approachVelocityMag to relTargetPosition:mag / (obt:period/12).
lock approachVelocity to approachVelocityMag * relTargetPosition/relTargetPosition:mag.
lock velocityDelta to approachVelocity - relTargetVelocity.

on round(time:seconds) {
  print velocityToTargetMag.
  clearVecDraws().
  vecDraw(v(0, 0, 0), relTargetPosition, white, "relTargetPosition", 1, true).
  vecDraw(v(0, 0, 0), relTargetVelocity, white, "relTargetVelocity", 1, true).
  vecDraw(v(0, 0, 0), velocityToTarget, white, "velocityToTarget", 1, true).
  vecDraw(v(0, 0, 0), approachVelocity, blue, "approachVelocity", 1, true).
  vecDraw(v(0, 0, 0), velocityDelta, blue, "velocityDelta", 1, true).
  preserve.
}

sas off.
lock steering to velocityDelta.


until relTargetPosition:mag < 100 {
  wait until velocityToTargetMag < 0.
  lock throttle to 0.2 * (1 - min(steeringManager:angleError, 2)/2).
  wait until velocityDelta:mag < 1.
  lock throttle to 0.
}
