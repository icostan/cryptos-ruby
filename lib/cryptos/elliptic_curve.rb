module Cryptos
  module EllipticCurve
    Group = Struct.new :gx, :gy, :prime, :order, :cofactor
    Secp256k1 = Group.new 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
                          0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8,
                          0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F,
                          0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
                          1
  end
end

EC_Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
EC_Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
EC_p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
EC_n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

LOW_S = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0

#
# Elliptic Curve
#
def extended_euclidean_algorithm(a, b)
  s, old_s = 0, 1
  t, old_t = 1, 0
  r, old_r = b, a
  while r != 0
    quotient = old_r / r
    old_r, r = r, old_r - quotient * r
    old_s, s = s, old_s - quotient * s
    old_t, t = t, old_t - quotient * t
  end
  [old_r, old_s, old_t]
end
def inverse(n, p)
  gcd, x, y = extended_euclidean_algorithm(n, p)
  (n * x + p * y) % p == gcd || raise('invalid gcd')
  gcd == 1 || raise('no multiplicative inverse')
  x % p
end
def ec_double(px, py, pn)
  i_2y = inverse(2 * py, pn)
  slope = (3 * px**2 * i_2y) % pn
  x = (slope**2 - 2 * px) % pn
  y = (slope*(px - x) - py) % pn
  [x, y]
end
def ec_add(ax, ay, bx, by, pn)
  return [ax, ay] if bx == 0 && by == 0
  return [bx, by] if ax == 0 && ay == 0
  return ec_double(ax, ay, pn) if ax == bx && ay == by

  i_bax = inverse(ax - bx, pn)
  slope = ((ay - by) * i_bax) % pn
  x = (slope**2 - ax - bx) % pn
  y = (slope*(ax - x) - ay) % pn
  [x, y]
end
def ec_multiply(m, px, py, pn)
  nx, ny = px, py
  qx, qy = 0, 0
  while m > 0
    qx, qy = ec_add qx, qy, nx, ny, pn if m&1 == 1
    nx, ny = ec_double nx, ny, pn
    m >>= 1
  end
  [qx, qy]
end

#
# ECDSA
#
def ecdsa_sign(private_key, digest, temp_key = nil)
  temp_key ||= Cryptos::PrivateKey.generate.value
  rx, _ry = ec_multiply(temp_key, EC_Gx, EC_Gy, EC_p)
  r = rx % EC_n
  r > 0 || raise('r is zero, try again new temp key')
  i_tk = inverse temp_key, EC_n
  m = bytes_to_bignum digest
  s = (i_tk * (m + r * private_key)) % EC_n
  s > 0 || raise('s is zero, try again new temp key')
  if s > LOW_S
    # https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#low-s-values-in-signatures
    # puts 'WARN: s is too big, use low s values'
    s = (EC_n - s) % EC_n
  end
  [r, s]
end

def ecdsa_verify?(px, py, digest, signature)
  r, s = signature
  i_s = inverse s, EC_n
  m = bytes_to_bignum digest
  u1 = i_s * m % EC_n
  u2 = i_s * r % EC_n
  u1Gx, u1Gy = ec_multiply u1, EC_Gx, EC_Gy, EC_p
  u2Px, u2Py = ec_multiply u2, px, py, EC_p
  rx, _ry = ec_add u1Gx, u1Gy, u2Px, u2Py, EC_p
  r == rx
end
