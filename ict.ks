
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
  if tAn > 180 { return 360 - eAn. }
  else { return eAn. }
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

function etaToAlt {
  declare parameter o.
  declare parameter alt.
  local tE to eccentricAnFromTrueAn(o, trueAnomalyAtAlt(o, alt)).
  local E to eccentricAnFromTrueAn(o, o:trueAnomaly).
  local result to sqrt(o:semiMajorAxis^3 / body:mu) * (constant:degToRad*(tE - E) - o:eccentricity*sin(tE - E)).
  // if result < 0 {
  //   set result to result + o:period.
  // }
  return result.
}

function absMeanAnomaly {
  declare parameter o.
  return mod(o:argumentOfPeriapsis + o:lan + meanAnFromEccentricAn(o, eccentricAnFromTrueAn(o, o:trueAnomaly)), 360).
}

lock angleOffset to positiveMod(absMeanAnomaly(ship:obt) - absMeanAnomaly(target:obt), 360).
set meanAngleOffset to (ship:obt:lan + ship:obt:argumentOfPeriapsis) - (target:obt:lan + target:obt:argumentOfPeriapsis).

print "angOff  " + fmt(angleOffset).
print "mAngOff " + fmt(meanAngleOffset).
print "tgtTAn  " + fmt(target:obt:trueAnomaly).
print "tgtTAn' " + fmt(mod(ship:obt:trueAnomaly + meanAngleOffset, 360)).



// function rotVec {
//   declare parameter a.
//   return angleAxis(a, sth)*prime.
// }
// clearVecDraws().
// set prime to solarPrimeVector*body:radius*1.5.
// set sth to body:angularVel:normalized*body:radius*1.5.
// vecDraw(body:position, prime, white, "Prime", 1.0, true).
// vecDraw(body:position, sth, white, "South", 1.0, true).
// vecDraw(body:position, rotVec(absMeanAnomaly(ship:obt)), white, "Ship", 1.0, true).
// vecDraw(body:position, rotVec(ship:obt:lan + ship:obt:argumentOfPeriapsis), white, "Ship PE", 1.0, true).
// vecDraw(body:position, rotVec(target:obt:lan + target:obt:argumentOfPeriapsis), white, "Target PE", 1.0, true).
// vecDraw(body:position, rotVec(absMeanAnomaly(target:obt)), white, "Target", 1.0, true).
// vecDraw(body:position, rotVec(target:obt:trueAnomaly + target:obt:lan + target:obt:argumentOfPeriapsis), white, "Target''", 1.0, true).

lock pSyn to (ship:obt:period * target:obt:period)/(ship:obt:period - target:obt:period).
set timeToTrans to (PSyn/360)*angleOffset.
// set timeToTrans to 600.
lock transTrueAnomaly to ship:obt:trueAnomaly + constant:radToDeg*timeToTrans*sqrt(body:mu/ship:obt:semiMajorAxis^3).
lock intersectAlt to altAtTrueAnomaly(target:obt, transTrueAnomaly + 180 + meanAngleOffset).

lock transSemiMajorAxis to body:radius + (altitude + intersectAlt)/2.
lock transDeltaVMag to sqrt(body:mu * (2/(body:radius + altitude) - 1/transSemiMajorAxis)).
lock transDuration to constant:pi*sqrt(transSemiMajorAxis^3 / body:mu).
lock pSyn to (ship:obt:period * target:obt:period)/(ship:obt:period - target:obt:period).

// lock targetIntersectPos to positionAt(target, time + timeToTrans + transDuration).
// lock futurePos to positionAt(ship, time + timeToTrans + transDuration).
// lock targetIntersectAlt to body:altitudeOf(targetIntersectPos).
//
// lock timeToTransErr to positiveMod(etaToAlt(target:obt, targetIntersectAlt) - transDuration, pSyn).
lock timeToTransErr to etaToAlt(target:obt, intersectAlt) - mod(timeToTrans + transDuration, target:obt:period).
//
// lock intersectAltErr to intersectAlt - targetIntersectAlt.
// lock futurePosErr to (targetIntersectPos - futurePos):mag.

set count to 0.
until count >= 0 {
  print fmt(intersectAlt) + " " + fmt(etaToAlt(target:obt, intersectAlt)/60) + " " + fmt(timeToTrans/60) + " " + fmt(timeToTransErr/60).
  set timeToTrans to timeToTrans + timeToTransErr.

  // if abs(intersectAltErr) < 10 and futurePosErr < 5000 {
  //   break.
  // }
  // set intersectAlt to targetIntersectAlt.
  // if  abs(intersectAltErr) < 1 {
  //   // set timeToTrans to (timeToTrans + timeToTransErr)/2.
  // }

  set count to count + 1.
}

print "intAlt  " + fmt(intersectAlt).


set n to NODE(time:seconds, 0, 0, 0).
set n:prograde to transDeltaVMag - velocity:orbit:mag.
set n:eta to timeToTrans.
add n.
