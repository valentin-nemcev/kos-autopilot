runOncePath("lib_control").


set altOffset to 15.


when stage:liquidfuel < 0.1 and stage:solidfuel < 0.1 and stage:ready then {
  stage.
  preserve.
}

lock horizontalDeltaV to -vxcl(ship:up:vector, ship:obt:velocity:surface).
lock verticalVelocityMag to ship:verticalSpeed.

sas off.
rcs off.

if horizontalDeltaV:mag > 5 {
  lock steering to horizontalDeltaV.
  wait 10.
  burn(horizontalDeltaV@).
  unlock steering.
}

lock terrainAlt to altitude - geoPosition:terrainHeight - altOffset.
lock suicideAccMag to 0.5*verticalVelocityMag^2/terrainAlt.
lock suicideDuration to abs(verticalVelocityMag/suicideAccMag).
lock gAccMag to body:mu/(body:radius + altitude)^2.
function trimAcc {
  if verticalVelocityMag > -1.5 return 0.
  return suicideAccMag.
}
lock suicideAccMagTrim to trimAcc().
lock suicideAcc to up:vector*(suicideAccMagTrim + gAccMag) + horizontalDeltaV/max(5, suicideDuration/2).

lock steering to suicideAcc.
gear on.
wait until suicideAcc:mag > ship:availableThrust/ship:mass * 0.9.
burnAcc({
  if verticalVelocityMag < -0.25 {
    return suicideAcc.
  } else {
    print terrainAlt.
    print alt:radar.
    return v(0, 0, 0).
  }
}).
lock steering to lookDirUp(up:vector, ship:facing:upvector).
wait 5.
