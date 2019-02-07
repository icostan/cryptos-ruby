module Cryptos
  module Monero
    # Private spend key
    class PrivateSpendKey < Cryptos::PrivateKey
      def initialize(value)
        super value, Cryptos::EllipticCurve::Ed25519.order, true
      end

      # Generate private view key
      # @return [Cryptos::Monero::PrivateViewKey] the private view key instance
      def private_view_key
        bytes = bignum_to_bytes value, nil, true, true
        # puts bytes.unpack('C*').join ','
        digest = Digest::SHA3.digest bytes, 256
        key = bytes_to_bignum digest.reverse
        key = key % order
        Cryptos::Monero::PrivateViewKey.new key
      end
    end
  end
end
