RSpec.describe Litecoin do
  describe Litecoin::Address do
    it '.from_pk' do
      k = 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
      public_key = bitcoin_new_public_key k
      expect(public_key).to eq '0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352'
      address = Litecoin::Address.from_pk public_key
      expect(address.to_s).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
      address = Litecoin::Address.from_pk public_key, 0x30
      expect(address.to_s).to eq 'LhavsnvcPEguCjzzuivpTFvYZ5vPWWHpbx'
    end
  end
end
