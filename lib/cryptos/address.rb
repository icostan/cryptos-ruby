module Cryptos
  class Address
    include Base58, Utils::Hashes
    extend Base58, Utils::Hashes

    attr_reader :public_key
    attr_reader :testnet

    def initialize(public_key, testnet: true)
      @public_key = public_key
      @testnet = testnet
    end

    #
    # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
    #
    def generate(network)
      prefix = network.to_s(16).rjust 2, '0'
      ripemd160 = hash160 public_key.to_sec
      with_version = "#{prefix}#{ripemd160}"
      checksum = hash256(with_version)[0, 8]
      wrap_encode = "#{with_version}#{checksum}"
      base58_encode(wrap_encode)
    end

    def self.to_hash160(value)
      base58_decode(value)[2, 40]
    end

    def to_hash160
      hash160(public_key.to_sec)
    end

    def p2pkh
      generate p2pkh_prefix
    end

    def p2sh
      generate p2sh_prefix
    end

    def to_s
      p2pkh
    end
  end
end
