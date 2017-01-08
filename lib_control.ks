@LAZYGLOBAL off.

function getTotalThrust {
  local thrustTotal is 0.
  local englist to list().
  list engines IN englist.
  for eng in englist {
    if eng:ignition {
      local t is eng:maxthrust*eng:thrustlimit/100.
      set thrustTotal TO thrustTotal + t.
    }
  }
  return thrustTotal.
}

function getIsp {
  // thrust weighted average isp
  local thrustTotal is 0.
  local mDotTotal is 0.
  local englist to list().
  list engines IN englist.
  for eng in englist
  {
      if eng:IGNITION
      {
          local t is eng:maxthrust*eng:thrustlimit/100. // if multi-engine with different thrust limiters
          set thrustTotal TO thrustTotal + t.
          if eng:isp = 0 set mDotTotal TO 1. // shouldn't be possible, but ensure avoiding divide by 0
          else set mDotTotal TO mDotTotal + t / eng:isp.
      }
  }
  if mDotTotal = 0 local isp is 0.
  else local isp is thrustTotal/mDotTotal.
  return isp.
}

function getBurntime {
  parameter deltaVMag.
  local g0 to 9.82.
  local isp to getIsp().
  local finalMass to ship:mass * constant:e^(-deltaVMag / (isp * g0)).
  return (ship:mass - finalMass) / (getTotalThrust() / (isp * g0)).
}

function getShipThrust {
  local totalThrust to 0.
  local englist to list().
  list engines in englist.
  for eng in englist {
      if eng:ignition set totalThrust to totalThrust + eng:thrust.
  }
  return totalThrust.
}

function getShipVacuumThrust {
  local totalThrust to 0.
  local englist to list().
  list engines in englist.
  for eng in englist {
      if eng:ignition set totalThrust to totalThrust + eng:thrust/eng:isp*eng:vacuumIsp.
  }
  return totalThrust.
}


function burn {
  parameter deltaVDelegate.
  lock deltaV to deltaVDelegate().

  when ship:availableThrust = 0 then "Available thrust is 0".
  local burnTimeMin to 0.5.
  local maxSteeringError to 2.5.

  lock accTh to min(1, deltaV:mag/(ship:availableThrust/ship:mass)/burnTimeMin).
  lock steeringTh to min(vang(ship:facing:vector, deltaV)/maxSteeringError, 1).
  lock throttle to max(0.01, (1 - steeringTh) * accTh).

  wait until deltaV:mag < 0.05 or vang(ship:facing:vector, deltaV) > 90.

  lock throttle to 0.
}

function burnAcc {
  parameter accDelegate.
  lock acc to accDelegate().

  if ship:availableThrust = 0 print "Available thrust is 0".
  local maxSteeringError to 2.5.

  lock accTh to min(1, acc:mag/(ship:availableThrust/ship:mass)).
  lock steeringTh to min(vang(ship:facing:vector, acc)/maxSteeringError, 1).
  lock throttle to max(0.01, (1 - steeringTh) * accTh).

  wait until acc:mag < 0.5.

  lock throttle to 0.
}
