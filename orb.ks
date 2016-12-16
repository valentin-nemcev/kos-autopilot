
set myAlt to obt:semiMajorAxis * (1 - obt:eccentricity^2) / (1 + obt:eccentricity*cos(obt:trueAnomaly)) - body:radius.

set tAn to arccos((obt:semiMajorAxis * (1 - obt:eccentricity^2) / (body:radius + altitude) - 1) / obt:eccentricity).

set E to arccos((obt:eccentricity + cos(tAn) / (1 + obt:eccentricity*cos(tAn)))).

set t to sqrt(obt:semiMajorAxis^3 / body:mu) * (constant:degToRad*E - obt:eccentricity*sin(E)).
print myAlt.
print tAn.
print E.
print t/60.
