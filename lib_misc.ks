@LAZYGLOBAL off.

function vectorProjection {
  parameter a.
  parameter b.
  return ((a * b) / (b * b)) * b.
}

function scalarProjection {
  parameter a.
  parameter b.
  if b:mag = 0 return 0.
  return (a * b) / b:mag.
}

function vectorAngleCos {
  parameter a.
  parameter b.
  if a:mag = 0 or b:mag = 0 return 0.
  return (a * b) / (a:mag * b:mag).
}

function bound {
  declare parameter lowerBound.
  declare parameter x.
  declare parameter upperBound.
  return min(max(lowerBound, x), upperBound).
}

function sign {
  parameter x.
  if x = 0 { return 0. }
  if x > 0 { return 1. }
  if x < 0 { return -1. }
}

function div {
  parameter a.
  parameter b.
  return (a - mod(a, b)) / b.
}

function positiveMod {
  declare parameter a.
  declare parameter b.
  return mod(b + mod(a, b), b).
}

function fmt {
  declare parameter n.
  declare parameter width is 8.
  declare parameter precision is 0.
  return ("" + round(n, precision)):padLeft(width).
}
