function avgIsp {
  // thrust weighted average isp
  local thrustTotal is 0.
  local mDotTotal is 0.
  list ENGINES IN englist.
  for eng in englist
  {
      if eng:IGNITION
      {
          local t is eng:maxthrust*eng:thrustlimit/100. // if multi-engine with different thrust limiters
          SET thrustTotal TO thrustTotal + t.
          if eng:isp = 0 SET mDotTotal TO 1. // shouldn't be possible, but ensure avoiding divide by 0
          else SET mDotTotal TO mDotTotal + t / eng:isp.
      }
  }
  if mDotTotal = 0 local isp is 0.
  else local isp is thrustTotal/mDotTotal.
  return isp.
}

function getShipThrust {
  set totalThrust to 0.

  list engines in englist.
  for eng in englist {
      if eng:ignition set totalThrust to totalThrust + eng:thrust.
  }
  return totalThrust.
}

function getShipVacuumThrust {
  set totalThrust to 0.

  list engines in englist.
  for eng in englist {
      if eng:ignition set totalThrust to totalThrust + eng:thrust/eng:isp*eng:vacuumIsp.
  }
  return totalThrust.
}


function burn {
  parameter deltaVDelegate.
  lock deltaV to deltaVDelegate().

  if ship:availableThrust = 0 print "Available thrust is 0".
  set burnTimeMin to 0.5.
  set maxSteeringError to 2.5.

  set deltaVFullMag to deltaV:mag.

  lock accTh to min(1, deltaV:mag/(ship:availableThrust/ship:mass)/burnTimeMin).
  lock steeringTh to min(vang(ship:facing:vector, deltaV)/maxSteeringError, 1).
  lock throttle to max(0.01, (1 - steeringTh) * accTh).

  wait until deltaV:mag < 0.05.

  lock throttle to 0.
}

function burnAcc {
  parameter accDelegate.
  lock acc to accDelegate().

  if ship:availableThrust = 0 print "Available thrust is 0".
  set maxSteeringError to 2.5.

  lock accTh to min(1, acc:mag/(ship:availableThrust/ship:mass)).
  lock steeringTh to min(vang(ship:facing:vector, acc)/maxSteeringError, 1).
  lock throttle to max(0.01, (1 - steeringTh) * accTh).

  wait until acc:mag < 0.5.

  lock throttle to 0.
}
