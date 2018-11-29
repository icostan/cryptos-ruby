module Cryptos
  module Utils
    module Hexas
      include Bytes

      def bin_to_hex(binary_bytes)
        binary_bytes.unpack('H*').first
      end

      def byte_to_hex(value)
        bin_to_hex [value].pack('C')
      end

      def bytes_to_hex(value)
        bin_to_hex value.pack('C*')
      end

      def int_to_hex(value)
        bin_to_hex [value].pack('V')
      end

      def long_to_hex(value)
        bin_to_hex [value].pack('Q<')
      end

      def bignum_to_hex(value, size = 32)
        bin_to_hex bignum_to_bytes(value, size)
      end

      def hex_to_little(value)
        bin_to_hex [value].pack('H*').reverse
      end

      def hex_size(hex)
        [hex].pack('H*').size
      end
    end
  end
end
