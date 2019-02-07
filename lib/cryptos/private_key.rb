require 'securerandom'

module Cryptos
  class PrivateKey
    attr_reader :value, :order, :little

    # Generates new private key
    # @param group [EllipticCurve::Group] EC group this
    # @return the private key
    def self.generate(group = EllipticCurve::Secp256k1)
      value = 1 + SecureRandom.random_number(group.order - 1)
      new value, group.order
    end

    def initialize(value, order = nil, little = false)
      @value = value
      @order = order
      @little = little
    end

    def to_s
      value.to_s
    end

    # Hex representation
    # @return key as hex
    def to_hex
      bytes = bignum_to_bytes(value, nil, true, little)
      bytes.unpack('H*').first
    end
  end
end
