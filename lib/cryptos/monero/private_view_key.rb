module Cryptos
  module Monero
    class PrivateViewKey < Cryptos::PrivateKey
      def initialize(value)
        super value, Cryptos::EllipticCurve::Ed25519.order, true
      end
    end
  end
end
