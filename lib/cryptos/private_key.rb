require 'securerandom'

module Cryptos
  class PrivateKey
    attr_reader :value, :order

    # Generates new private key
    # @param group [EllipticCurve::Group] EC group this
    # @return the private key
    def self.generate(group = EllipticCurve::Secp256k1)
      value = 1 + SecureRandom.random_number(group.order - 1)
      new value, group.order
    end

    def initialize(value, order = nil)
      @value = value
      @order = order
    end

    def to_s
      value.to_s
    end
  end
end
