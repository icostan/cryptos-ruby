module Cryptos
  module Base58
    include Utils::Bytes

    def base58_encode(ripe160_hash)
      alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
      value = ripe160_hash.to_i 16
      output = ''
      while value > 0
        remainder = value % 58
        value /= 58
        output += alphabet[remainder]
      end
      output += alphabet[0] * [ripe160_hash].pack('H*').bytes.find_index{|b| b != 0}
      output.reverse
    end

    def base58_decode(address)
      alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
      int_val = 0
      address.reverse.chars.each_with_index do |char, index|
        char_index = alphabet.index(char)
        int_val += char_index * 58**index
      end
      # TODO: hard coded 25 bytes?
      bignum_to_bytes(int_val, 25).unpack('H*').first
    end
  end
end
