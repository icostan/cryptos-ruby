module Cryptos
  Der = Struct.new :der, :length, :ri, :rl, :r, :si, :sl, :s, :sighash_type do
    def initialize(der: 0x30, length: 0x44, ri: 0x02, rl: 0x20, r: nil, si: 0x02, sl: 0x20, s: nil, sighash_type: 0x01)
      super der, length, ri, rl, r, si, sl, s, sighash_type
    end

    def serialize
      r_bytes = bignum_to_bytes(r, 32, false)
      if r_bytes.first & 0x80 == 128
        r_bytes = [0x00] + r_bytes
        self.length += 1
        self.rl += 1
      end
      byte_to_hex(der) + byte_to_hex(length) +
        byte_to_hex(ri) + byte_to_hex(rl) + bytes_to_hex(r_bytes) +
        byte_to_hex(si) + byte_to_hex(sl) + to_hex(bignum_to_bytes(s, 32)) +
        byte_to_hex(sighash_type)
    end

    def self.parse(signature)
      fields = *[signature].pack('H*').unpack('CCCCH66CCH64C')
      Der.new r: fields[4], s: fields[7], sighash_type: fields[8]
    end
  end
end
