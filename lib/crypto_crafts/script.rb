class Script
  def self.for_address(address)
    hash160 = address.to_hash160
    if address.to_s.start_with? '2'
      "OP_HASH160 #{hash160} OP_EQUAL"
    else
      p2pkh hash160
    end
  end

  def self.for_public(pa)
    p2pkh Address.to_hash160 pa
  end

  def self.p2pkh(hash160)
    "OP_DUP OP_HASH160 #{hash160} OP_EQUALVERIFY OP_CHECKSIG"
  end
end
