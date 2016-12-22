
function bound {
  declare parameter lowerBound.
  declare parameter x.
  declare parameter upperBound.
  return min(max(lowerBound, x), upperBound).
}

function sign {
  parameter x.
  if x = 0 { return 0. }
  if x > 0 { return 1. }
  if x < 0 { return -1. }
}

function div {
  parameter a.
  parameter b.
  return (a - mod(a, b)) / b.
}

function positiveMod {
  declare parameter a.
  declare parameter b.
  return mod(b + mod(a, b), b).
}

function fmt {
  declare parameter n.
  declare parameter width is 8.
  declare parameter precision is 0.
  return ("" + round(n, precision)):padLeft(width).
}


function deltaMeanAnFromDeltaTime {
  parameter o.
  parameter t.
  return constant:radToDeg*t*sqrt(o:body:mu/o:semiMajorAxis^3).
}

function meanAnFromEccentricAn {
  declare parameter o.
  declare parameter eAn.
  return eAn - o:eccentricity*sin(eAn).
}

function eccentricAnFromTrueAn {
  declare parameter o.
  declare parameter tAn.
  local cosE to (o:eccentricity + cos(tAn) / (1 + o:eccentricity*cos(tAn))).
  local eAn to arccos(bound(-1, cosE, 1)).
  local tAnMod to mod(tAn, 360).
  if tAnMod > 180 { return tAn - tAnMod + 360 - eAn. }
  else { return tAn - tAnMod + eAn. }
}

function trueAnomalyAtAlt {
  declare parameter o.
  declare parameter alt.
  local cosTAn to (o:semiMajorAxis * (1 - o:eccentricity^2) / (o:body:radius + alt) - 1) / o:eccentricity.
  local tAn to arccos(bound(-1, cosTAn, 1)).
  return tAn.
}

function altAtTrueAnomaly {
  declare parameter o.
  declare parameter tAn.
  return o:semiMajorAxis * (1 - o:eccentricity^2) / (1 + o:eccentricity*cos(tAn)) - o:body:radius.
}

function trueAnFromEccentricAn {
  parameter o.
  parameter eAn.
  local tAn to 180 - 2 * arctan2(sqrt(1 - o:eccentricity)*cos(eAn/2), sqrt(1 + o:eccentricity)*sin(eAn/2)).
  return tAn.
}

function eccentricAnFromMeanAn {
  parameter o.
  parameter meanAn.
  local eAn to meanAn.
  local count to 0.
  until count >= 5 {
    set eAn to meanAn + o:eccentricity*sin(eAn).
    set count to count + 1.
  }
  return eAn.
}

function eccentricAnAtTime {
  parameter o.
  parameter t.
  local meanAn to meanAnFromEccentricAn(o, eccentricAnFromTrueAn(o, o:trueAnomaly)).
  local timeOfPe to time:seconds - o:period/360*meanAn.
  local meanAnAtT to (t - timeOfPe) / o:period*360.
  return eccentricAnFromMeanAn(o, meanAnAtT).
}

function deltaTimeBetweenEAn {
  parameter o.
  parameter eAnS.
  parameter eAnF.
  return sqrt(o:semiMajorAxis^3 / o:body:mu) * (constant:degToRad*(eAnF - eAnS) - o:eccentricity*sin(eAnF - eAnS)).
}

function etaToAlt {
  declare parameter o.
  declare parameter alt.
  local tE to eccentricAnFromTrueAn(o, trueAnomalyAtAlt(o, alt)).
  local E to eccentricAnFromTrueAn(o, o:trueAnomaly).
  local result to sqrt(o:semiMajorAxis^3 / body:mu) * (constant:degToRad*(tE - E) - o:eccentricity*sin(tE - E)).
  return result.
}

function absMeanAnomaly {
  declare parameter o.
  return mod(o:argumentOfPeriapsis + o:lan + meanAnFromEccentricAn(o, eccentricAnFromTrueAn(o, o:trueAnomaly)), 360).
}


lock angleOffset to positiveMod(absMeanAnomaly(ship:obt) - absMeanAnomaly(target:obt), 360).
set meanAngleOffset to (ship:obt:lan + ship:obt:argumentOfPeriapsis) - (target:obt:lan + target:obt:argumentOfPeriapsis).

lock synFreq to 1/target:obt:period - 1/ship:obt:period.
set timeToTrans to 1/(360*synFreq)*angleOffset - ship:obt:period/2.
lock transTrueAnomaly to ship:obt:trueAnomaly + deltaMeanAnFromDeltaTime(ship:obt, timeToTrans).
lock targetPredictedIntersectTAn to  transTrueAnomaly + 180 + meanAngleOffset.
lock intersectAlt to altAtTrueAnomaly(target:obt, targetPredictedIntersectTAn).

lock transSemiMajorAxis to body:radius + (altitude + intersectAlt)/2.
lock transDeltaVMag to sqrt(body:mu * (2/(body:radius + altitude) - 1/transSemiMajorAxis)).
lock transDuration to constant:pi*sqrt(transSemiMajorAxis^3 / body:mu).

print "tgtTAn  " + fmt(target:obt:trueAnomaly, 8, 4).
print "tgtTAn' " + fmt(trueAnFromEccentricAn(target:obt, eccentricAnAtTime(target:obt, time:seconds)), 8, 4).

lock targetPredictedIntersectEAn to eccentricAnFromTrueAn(target:obt, targetPredictedIntersectTAn).
lock targetActualIntersectEAn to eccentricAnAtTime(target:obt, time:seconds+timeToTrans+transDuration).
lock targetIntersectEAnErr to targetActualIntersectEAn - targetPredictedIntersectEAn.
lock targetIntersectDeltaT to deltaTimeBetweenEAn(target:obt, targetActualIntersectEAn, targetPredictedIntersectEAn).
lock timeToTransErr to sign(targetIntersectEAnErr) * 1/(1/abs(targetIntersectDeltaT) - 1/(abs(targetIntersectEAnErr)*ship:obt:period/360)).
set lastTimeTransErr to 100.
set count to 0.
until count >= 15 or abs(lastTimeTransErr) < 0.5 {
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
add n.
