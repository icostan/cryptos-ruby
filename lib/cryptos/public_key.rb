module Cryptos
  class PublicKey
    attr_reader :x, :y, :private_key

    def initialize(private_key)
      @private_key = private_key
      @x, @y = *ec_multiply(private_key.value, EC_Gx, EC_Gy, EC_p)
    end

    def check!
      (x**3 + 7 - y**2) % EC_p == 0 || raise('public key point is not on the curve')
    end

    # Serialize public key as SEC (Standards for Efficient Cryptography) format
    # @param compressed [true, false] the format to return, either compressed or uncompressed
    # @return address in SEC format
    def to_sec(compressed = true)
      if compressed
        "#{y.even? ? '02' : '03'}#{x_to_sec}"
      else
        "04#{x_to_sec}#{y_to_sec}"
      end
    end

    def coordinates
      [x, y]
    end

    def to_s
      coordinates.to_s
    end

    private

    def x_to_sec
      to_hex bignum_to_bytes(x, 32)
    end

    def y_to_sec
      to_hex bignum_to_bytes(y, 32)
    end
  end
end
