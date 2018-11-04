class PublicKey
  attr_reader :x, :y

  def self.from_pk(private_key)
    new *ec_multiply(private_key.value, EC_Gx, EC_Gy, EC_p)
  end

  def initialize(x, y)
    @x = x
    @y = y
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
end
