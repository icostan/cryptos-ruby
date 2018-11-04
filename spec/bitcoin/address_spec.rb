require 'spec_helper'

RSpec.describe Bitcoin do
  describe Bitcoin::Address do
    it '.from_pk' do
      k = PrivateKey.new 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
      public_key = PublicKey.from_pk k
      expect(public_key.compressed).to eq '0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352'
      address = Bitcoin::Address.from_pk public_key
      expect(address.to_s).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
      address = Bitcoin::Address.from_pk public_key, 0x00
      expect(address.to_s).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
    end
    it '#to_hash160' do
      address = Bitcoin::Address.new '2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn'
      expect(address.to_hash160).to eq 'f81498040e79014455a5e8f7bd39bce5428121d3'
    end
  end
end
