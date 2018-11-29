module Cryptos
  module Utils
    module Bytes
      def bytes_to_bignum(bytes_string)
        bytes_string.bytes.reduce { |n, b| (n << 8) + b }
      end

      def bignum_to_bytes(n, length=nil, stringify=true)
        a = []
        while n > 0
          a << (n & 0xFF)
          n >>= 8
        end
        a.fill 0x00, a.length, length - a.length if length
        bytes = a.reverse
        stringify ? bytes.pack('C*') : bytes
      end
    end
  end
end
