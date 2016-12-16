print target:orbit:period.

declare pSyn to 60 * 60 * 6.

declare finalP to (target:orbit:period * pSyn) / (pSyn - target:orbit:period).

declare finalAlt to ((body:mu * finalP^2) / (4 * constant:pi^2))^(1/3) - body:radius.
print finalP.
print finalAlt.
