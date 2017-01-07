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
  parameter o.
  parameter tAn.

  if (o:eccentricity < 1) {
    local tAnRem to mod(tAn, 360).
    local tAnQd to tAn - tAnRem.
    return tAnQd + 2*arctan2(sqrt((1 - o:eccentricity)/(1 + o:eccentricity))*sin(tAnRem/2), cos(tAnRem/2)).
  } else {
    return 2*arctanh(sqrt((o:eccentricity - 1)/(o:eccentricity + 1)) * tan(tAn/2)).
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
  print eAnS.
  print eAnF.
  local invN is sqrt(abs(o:semiMajorAxis)^3 / o:body:mu).
  if o:eccentricity < 1 {
    return invN * ((constant:degToRad*eAnF - o:eccentricity*sin(eAnF)) - (constant:degToRad*eAnS - o:eccentricity*sin(eAnS))).
    return invN * (constant:degToRad*(eAnF - eAnS) - o:eccentricity*sin(eAnF - eAnS)).
  } else {
    return invN * ((o:eccentricity*sinh(eAnF) - constant:degToRad*eAnF) - (o:eccentricity*sinh(eAnS) - constant:degToRad*eAnS)).
  }

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
  return sqrt(body:mu * (2/(body:radius + fromAlt) - 1/transSemiMajorAxis)).
}

function absMeanAnomaly {
  declare parameter o.
  return mod(o:argumentOfPeriapsis + o:lan + meanAnFromEccentricAn(o, eccentricAnFromTrueAn(o, o:trueAnomaly)), 360).
}

function drawTAn {
  parameter o.
  parameter tAn.
  parameter alt to o:body:radius*0.25.
  local an to solarPrimeVector*angleAxis(-o:lan, o:body:north:vector).
  local obNorm to o:body:north:vector*angleAxis(-o:inclination, an).
  local ap to an*angleAxis(-o:argumentOfPeriapsis, obNorm).
  local v to ap*angleAxis(-tAn, obNorm).
  local vd to vecDraw(o:body:position, v*(o:body:radius+alt), blue, round(tAn, 1) + "@" + round(alt/1000)).
  set vd:show to true.
  return vd.
}


function drawEAn {
  parameter o.
  parameter eAn.
  local an to (solarPrimeVector*angleAxis(-o:lan, o:body:north:vector)):normalized.
  local obNorm to o:body:north:vector*angleAxis(-o:inclination, an).
  local ap to an*angleAxis(-o:argumentOfPeriapsis, obNorm).
  local c to o:body:position + ap*(-o:semiMajorAxis*o:eccentricity).
  local a to ap*o:semiMajorAxis.
  local b to ap*angleAxis(-90, obNorm)*o:semiMajorAxis*sqrt(1 - o:eccentricity^2).
  local v to a * cos(eAn) + b * sin(eAn).
  local vd to vecDraw(c, v, green, round(eAn, 1)).
  set vd:show to true.
  return vd.
}
