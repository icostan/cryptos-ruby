require 'digest'

module Cryptos
  module Utils
    module Hashes
      def sha256(data)
        Digest::SHA256.hexdigest([data].pack('H*'))
      end

      def ripemd160(data)
        Digest::RMD160.hexdigest([data].pack('H*'))
      end

      def hash160(data)
        sha256 = Digest::SHA256.digest([data].pack('H*'))
        Digest::RMD160.hexdigest sha256
      end

      def hash256(data)
        sha256 = Digest::SHA256.digest([data].pack('H*'))
        Digest::SHA256.hexdigest sha256
      end
    end
  end
end
