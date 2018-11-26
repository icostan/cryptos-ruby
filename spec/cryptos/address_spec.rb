require 'spec_helper'

RSpec.describe Cryptos::Address do
  let(:k){ Cryptos::PrivateKey.new 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725 }
  let(:public_key){ PublicKey.from_pk k }

  xit '#to_hash160' do
    # address = Cryptos::Bitcoin::Address.new '2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn'
    address = Cryptos::Bitcoin::Address.new public_key
    expect(address.to_hash160).to eq 'f81498040e79014455a5e8f7bd39bce5428121d3'
  end

  it '.to_hash160' do
    value = Cryptos::Bitcoin::Address.to_hash160 '2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn'
    expect(value).to eq 'f81498040e79014455a5e8f7bd39bce5428121d3'
  end
end
