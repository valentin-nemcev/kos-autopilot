parameter targetPeKm.
parameter targetApKm to targetPeKm.

if targetPeKm > targetApKm {
  local tmp to targetApKm.
  set targetApKm to targetPeKm.
  set targetPeKm to tmp.
}

runOncePath("lib_misc").
runOncePath("lib_orbit").

global targetPe to targetPeKm * 1000.
global targetAp to targetApKm * 1000.

until not hasnode { remove nextnode. wait 0.1. }

function transferNode {
  parameter fromAlt.
  parameter toAlt.
  local targetPeTAn to trueAnFromHalfTrueAn(
    halfTrueAnomalyAtAlt(obt, fromAlt),
    obt:trueAnomaly
   ).
  print halfTrueAnomalyAtAlt(obt, fromAlt).
  print targetPeTAn.
  local etaToTargetPe to deltaTimeBetweenEAn(
    obt,
    eccentricAnFromTrueAn(obt, obt:trueAnomaly),
    eccentricAnFromTrueAn(obt, targetPeTAn)
   ).
  local pitch to pitchAtTAn(obt, targetPeTAn).
  local velMag to velocityMagAtTAn(obt, targetPeTAn).
  local targetVelMag to hohmannVelocityMag(fromAlt, toAlt).
  add node(
    time:seconds + etaToTargetPe,
    -targetVelMag*sin(pitch),
    0,
    targetVelMag*cos(pitch) - velMag
  ).
}

if obt:periapsis < targetPe and (targetPe < obt:apoapsis or obt:eccentricity >= 1) {
  transferNode(targetPe, targetAp).
  runPath("nd").
} else if obt:periapsis < targetAp and (targetAp < obt:apoapsis or obt:eccentricity >= 1) {
  transferNode(targetAp, targetPe).
  runPath("nd").
} else {
  transferNode(obt:periapsis, targetPe).
  runPath("nd").
  transferNode(targetPe, targetAp).
  runPath("nd").
}
