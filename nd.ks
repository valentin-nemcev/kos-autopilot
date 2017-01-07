runOncePath("lib_control").

global burntime to getBurntime(nextNode:deltaV:mag).
print "Burntime: " + round(burntime, 2) + "s".

global maneuverStartTS to nextNode:eta - ((burntime/2) + 30).

if maneuverStartTS < 0 {
  print "Missed node".
} else {
  print "Warping to +" +  (time - time:seconds + maneuverStartTS):clock.
  wait 3.
  kUniverse:timeWarp:warpTo(time:seconds + maneuverStartTS).

  sas off.
  lock steering to lookDirUp(nextNode:deltaV, ship:facing:topVector).

  wait until nextNode:eta < (burntime/2).

  burn({ return nextNode:deltaV. }).

  lock steering to "kill".

  wait 2.

  print "Maneuver complete, delta V left: " + round(nextNode:deltaV:mag, 4) + "m/s.".
  remove nextNode.
}
