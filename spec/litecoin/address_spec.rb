require 'spec_helper'

RSpec.describe Litecoin::Address do
  let(:k){ PrivateKey.new 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725 }
  let(:public_key){ PublicKey.from_pk k }

  describe 'mainnet' do
    let(:address){ Litecoin::Address.new public_key, testnet: false }

    it 'p2pkh' do
      expect(address.p2pkh).to eq 'LhavsnvcPEguCjzzuivpTFvYZ5vPWWHpbx'
      expect(address.to_s).to eq 'LhavsnvcPEguCjzzuivpTFvYZ5vPWWHpbx'
    end
    it 'p2sh' do
      expect(address.p2sh).to eq 'MWG8r1XBobceqcHAxZbTRWU7p6SGxLnE2h'
    end
  end

  describe 'testnet' do
    let(:address){ Litecoin::Address.new public_key }

    it 'p2pkh' do
      expect(address.p2pkh).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
      expect(address.to_s).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
    end
    it 'p2sh' do
      expect(address.p2sh).to eq 'QixxisuVV3KfP5Ps9vG1JWeQr8VpeTJ1de'
    end
  end
end
