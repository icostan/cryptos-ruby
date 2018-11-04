require 'digest'

module Hashing
  def hash160(data)
    sha256 = Digest::SHA256.digest([data].pack('H*'))
    Digest::RMD160.hexdigest sha256
  end

  def hash256(data)
    sha256 = Digest::SHA256.digest([data].pack('H*'))
    Digest::SHA256.hexdigest sha256
  end
end
