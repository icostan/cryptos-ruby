class PublicKey
  attr_reader :x, :y, :private_key

  def self.from_pk(private_key)
    new *ec_multiply(private_key.value, EC_Gx, EC_Gy, EC_p), private_key
  end

  def initialize(x, y, private_key)
    @x = x
    @y = y
    @private_key = private_key
  end

  def check!
    (x**3 + 7 - y**2) % EC_p == 0 || raise('public key point is not on the curve')
  end

  def compressed
    "#{y > 0 ? '02' : '03'}#{x.to_s(16)}"
  end

  def uncompressed
    "04#{x.to_s(16)}#{y.to_s(16)}"
  end

  def coordinates
    [x, y]
  end

  def to_s
    coordinates
  end
end
