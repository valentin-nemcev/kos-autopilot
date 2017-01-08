parameter targetApKm to 75.
parameter targetAz to 90.
parameter initialAngle to 20.

set targetAp to targetApKm * 1000.


lock throttle to 1.

set lncHeading to heading(targetAz, initialAngle).
gear off.

lock steering to lncHeading.
wait until vang(lncHeading:vector, velocity:orbit) < 5.
lock steering to heading(targetAz, 90 - vang(up:vector, velocity:orbit)).

wait until apoapsis > targetAp.
lock throttle to 0.

run crc2(targetApKm).
