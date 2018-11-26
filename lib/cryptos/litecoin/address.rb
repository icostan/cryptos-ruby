module Litecoin
  #
  # https://bitcoin.stackexchange.com/questions/65282/how-is-a-litecoin-address-generated
  # https://bitcoin.stackexchange.com/questions/62781/litecoin-constants-and-prefixes
  #
  class Address < ::Address
    def p2pkh_prefix
      testnet ? 0x6f : 0x30
    end

    def p2sh_prefix
      testnet ? 0x3a : 0x32
    end
  end
end
