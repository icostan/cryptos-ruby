module Cryptos
  module Bitcoin
    class Address < Cryptos::Address
      def p2pkh_prefix
        testnet ? 0x6f : 0x00
      end

      def p2sh_prefix
        testnet ? 0xc4 : 0x05
      end
    end
  end
end
