parameter soiOffset to 0.

runOncePath("lib_misc").
runOncePath("lib_orbit").



until not hasnode { remove nextnode. wait 0.1. }

print "Calculating maneuver to intercept " + target:name + "...".

lock rawAngleOffset to absMeanAnomaly(ship:obt) - absMeanAnomaly(target:obt).
lock angleOffset to positiveMod(rawAngleOffset * sign(ship:obt:period - target:obt:period), 360).
set meanAngleOffset to (ship:obt:lan + ship:obt:argumentOfPeriapsis) - (target:obt:lan + target:obt:argumentOfPeriapsis).

lock synFreq to abs(1/target:obt:period - 1/ship:obt:period).
set timeToTrans to 1/(360*synFreq)*angleOffset - ship:obt:period/2.

lock transTrueAnomaly to ship:obt:trueAnomaly + deltaMeanAnFromDeltaTime(ship:obt, timeToTrans).
lock targetPredictedIntersectTAn to transTrueAnomaly + 180 + meanAngleOffset.
if soiOffset <> 0 {
  set soiOffsetAlt to target:soiRadius*soiOffset.
} else {
  set soiOffsetAlt to 0.
}
lock intersectAlt to altAtTrueAnomaly(target:obt, targetPredictedIntersectTAn) + soiOffsetAlt.

lock transSemiMajorAxis to body:radius + (altitude + intersectAlt)/2.
lock transDeltaVMag to sqrt(body:mu * (2/(body:radius + altitude) - 1/transSemiMajorAxis)).
lock transDuration to constant:pi*sqrt(transSemiMajorAxis^3 / body:mu).

lock targetPredictedIntersectEAn to eccentricAnFromTrueAn(target:obt, targetPredictedIntersectTAn).
lock targetActualIntersectEAn to eccentricAnAtTime(target:obt, time:seconds+timeToTrans+transDuration).
lock targetIntersectEAnErr to targetActualIntersectEAn - targetPredictedIntersectEAn.
lock targetIntersectDeltaT to deltaTimeBetweenEAn(target:obt, targetActualIntersectEAn, targetPredictedIntersectEAn).
lock timeToTransErr to sign(targetIntersectEAnErr) * 1/(1/abs(targetIntersectDeltaT) - 1/(abs(targetIntersectEAnErr)*ship:obt:period/360)).
set lastTimeTransErr to 100.
set count to 0.
until count >= 5 or abs(lastTimeTransErr) < 0.5 {
  set lastTimeTransErr to timeToTransErr.

  print "- " + count.
  print "tgtPrEAn" + fmt(targetPredictedIntersectEAn).
  print "tgtAcEAn" + fmt(targetActualIntersectEAn).
  print "dT      " + fmt(targetIntersectDeltaT).
  print "intAlt  " + fmt(intersectAlt).
  print "tErr    " + fmt(lastTimeTransErr, 8, 4).

  set timeToTrans to timeToTrans - lastTimeTransErr.
  set count to count + 1.
}


set n to NODE(time:seconds, 0, 0, 0).
set n:prograde to transDeltaVMag - velocity:orbit:mag.
set n:eta to timeToTrans.
set n:eta to positiveMod(timeToTrans, 1/synFreq).
add n.
