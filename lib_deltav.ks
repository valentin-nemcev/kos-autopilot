@LAZYGLOBAL off.

global initialDeltaV to velocity:orbit.
global deltaV_Gained to 0.
global deltaV_prevV to velocity:orbit.
global deltaV_Spent to 0.
global deltaV_SpentVac to 0.
global deltaV_SpentG to 0.
global deltaV_SpentTurn to 0.
global deltaV_SpentOther to 0.

global accelTS to time:seconds.
global deltaV_SpentTS to time:seconds.
global deltaV_SpentVacTS to time:seconds.
global deltaV_SpentGTS to time:seconds.
global deltaV_SpentTurnTS to time:seconds.
global deltaV_SpentOtherTS to time:seconds.

global deltaV_integrate to false.

function deltaV_start {
  set deltaV_integrate to true.


}

function deltaV_update {
  local thrustAcc to (getShipThrust()/ship:mass) * ship:facing:vector.
  local vacuumThrustAcc to (getShipVacuumThrust()/ship:mass) * ship:facing:vector.

  local gAcc to -(body:mu/(body:radius + altitude)^2) * up:vector.

  local dv to (velocity:orbit - deltaV_prevV).
  set deltaV_prevV to velocity:orbit.

  local accel to dv/(time:seconds - accelTS).
  set accelTS to time:seconds.

  local otherAcc to accel - thrustAcc - gAcc.

  set deltaV_Gained to deltaV_Gained + dv:mag.

  set deltaV_Spent to deltaV_Spent + thrustAcc:mag*(time:seconds - deltaV_SpentTS).
  set deltaV_SpentTS to time:seconds.

  set deltaV_SpentVac to deltaV_SpentVac + vacuumThrustAcc:mag*(time:seconds - deltaV_SpentVacTS).
  set deltaV_SpentVacTS to time:seconds.

  local gAccLossMag to bound(-thrustAcc:mag, scalarProjection(gAcc, thrustAcc), 0).
  set deltaV_SpentG to deltaV_SpentG + gAccLossMag*(time:seconds - deltaV_SpentGTS).
  set deltaV_SpentGTS to time:seconds.

  local otherAccLossMag to bound(-(thrustAcc:mag + gAccLossMag), scalarProjection(otherAcc, thrustAcc), 0).
  set deltaV_SpentOther to deltaV_SpentOther + otherAccLossMag*(time:seconds - deltaV_SpentOtherTS).
  set deltaV_SpentOtherTS to time:seconds.

  local thrustTurnAcc to vxcl(velocity:orbit, thrustAcc).
  local thrustTurnAccMag to thrustTurnAcc:mag.
  set thrustTurnAccMag to thrustTurnAccMag + bound(-thrustTurnAccMag, scalarProjection(gAcc, thrustTurnAcc), 0).
  set thrustTurnAccMag to thrustTurnAccMag + bound(-thrustTurnAccMag, scalarProjection(otherAcc, thrustTurnAcc), 0).

  set deltaV_SpentTurn to deltaV_SpentTurn + thrustTurnAccMag*(time:seconds - deltaV_SpentTurnTS).
  set deltaV_SpentTurnTS to time:seconds.
}

function deltav_stop {
  set deltaV_integrate to false.
}

function deltaV_print {
  local finalDeltaV to velocity:orbit.
  local instantDeltaV to (finalDeltaV - initialDeltaV):mag.
  local deltaV_Rem to deltaV_Spent + deltaV_SpentG + deltaV_SpentOther.
  local deltaV_fwd to deltaV_Rem - deltaV_SpentTurn.
  print "dV stats:".
  print "inst| int| vac|-eng|  -g|-oth|turn| fwd| eff".
  print fmt(instantDeltaV, 4, 0) + " " +  fmt(deltaV_Gained, 4, 0)
   + " " + fmt(deltaV_SpentVac, 4, 0) + " " + fmt(deltaV_SpentVac-deltaV_Spent, 4, 0)
   + " " + fmt(-deltaV_SpentG, 4, 0) + " " + fmt(-deltaV_SpentOther, 4, 0)
   + " " + fmt(deltaV_SpentTurn, 4, 0) + " " + fmt(deltaV_fwd, 4, 0)
   + " " + fmt(deltaV_Rem / deltaV_SpentVac, 4, 2).
}
