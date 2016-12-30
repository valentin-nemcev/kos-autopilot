@LAZYGLOBAL off.

runOncePath("lib_misc").


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

function arcosh {
  parameter x.
  return constant:radToDeg * ln(x + sqrt(x^2 + 1)).
}

function arctanh {
  parameter x.
  return constant:radToDeg * 0.5*ln((1 + x)/(1 - x)).
}

function eccentricAnFromTrueAn {
  declare parameter o.
  declare parameter tAn.
  local cosE to (o:eccentricity + cos(tAn) / (1 + o:eccentricity*cos(tAn))).
  local eAn is 0.
  if (o:eccentricity < 1) {
    // TODO https://www.reddit.com/r/Kos/comments/4tm0wq/two_common_mistakes_people_make_when_calculating/d5ixeoi/
    set eAn to arccos(bound(-1, cosE, 1)).
    local tAnMod to mod(tAn, 360).
    if tAnMod > 180 { return tAn - tAnMod + 360 - eAn. }
    else { return tAn - tAnMod + eAn. }
  } else {
    return arctanh(sqrt((o:eccentricity - 1)/(o:eccentricity + 1)) * tan(tAn/2)).
  }

}

function halfTrueAnomalyAtAlt {
  declare parameter o.
  declare parameter alt.
  local cosTAn to (o:semiMajorAxis * (1 - o:eccentricity^2) / (o:body:radius + alt) - 1) / o:eccentricity.
  local tAn to arccos(bound(-1, cosTAn, 1)).
  return tAn.
}

function trueAnFromHalfTrueAn {
  parameter hTAn.
  parameter refTAn.
  local hTAn2 is 360 - hTAn.
  if hTAn >= refTAn return hTAn.
  if hTAn < refTAn and refTAn < hTAn2 return hTAn2.
  return 360 + hTAn.
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

function sinh {
  parameter x.
  set x to x*constant:degToRad.
  return (constant:e^x - constant:e^(-x))/2.
}

function deltaTimeBetweenEAn {
  parameter o.
  parameter eAnS.
  parameter eAnF.
  local invN is sqrt(abs(o:semiMajorAxis)^3 / o:body:mu).
  if o:eccentricity < 1 {
    return invN * (constant:degToRad*(eAnF - eAnS) - o:eccentricity*sin(eAnF - eAnS)).
  } else {
    return invN * ((o:eccentricity*sinh(eAnF) - constant:degToRad*eAnF) - (o:eccentricity*sinh(eAnS) - constant:degToRad*eAnS)).
  }

}

function etaToAlt {
  declare parameter o.
  declare parameter alt.
  local tE to eccentricAnFromTrueAn(o, trueAnomalyAtAlt(o, alt)).
  local E to eccentricAnFromTrueAn(o, o:trueAnomaly).
  local result to sqrt(o:semiMajorAxis^3 / body:mu) * (constant:degToRad*(tE - E) - o:eccentricity*sin(tE - E)).
  return result.
}

function pitchAtTAn {
  parameter o.
  parameter tAn.
  return arctan(o:eccentricity*sin(tAn)/(1 + o:eccentricity*cos(tAn))).
}

function velocityMagAtTAn {
  parameter o.
  parameter tAn.
  local r is altAtTrueAnomaly(o, tAn) + body:radius.
  return sqrt(body:mu*(2/r - 1/o:semiMajorAxis)).
}

function hohmannVelocityMag {
  parameter fromAlt.
  parameter toAlt.
  local transSemiMajorAxis to body:radius + (fromAlt + toAlt)/2.
  local s is 1.
  if abs(toAlt - fromAlt) > 1 set s to sign(toAlt - fromAlt).
  return s * sqrt(body:mu * (2/(body:radius + fromAlt) - 1/transSemiMajorAxis)).
}

function absMeanAnomaly {
  declare parameter o.
  return mod(o:argumentOfPeriapsis + o:lan + meanAnFromEccentricAn(o, eccentricAnFromTrueAn(o, o:trueAnomaly)), 360).
}
