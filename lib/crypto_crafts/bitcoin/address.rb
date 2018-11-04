module Bitcoin
  class Address
    include Base58, Hashing
    extend Base58, Hashing

    attr_reader :value, :public_key

    #
    # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
    #
    def self.from_pk(public_key, network = 0x6f)
      prefix = network.to_s(16).rjust 2, '0'
      ripemd160 = hash160 public_key.compressed
      with_version = "#{prefix}#{ripemd160}"
      checksum = hash256(with_version)[0, 8]
      wrap_encode = "#{with_version}#{checksum}"
      value = base58_encode(wrap_encode)
      new value, public_key
    end

    def initialize(value, public_key = nil)
      @value = value
      @public_key = public_key
    end

    def to_hash160
      public_key ? hash160(public_key.compressed) : base58_decode(value)[2, 40]
    end

    def to_s
      value
    end
  end
end
