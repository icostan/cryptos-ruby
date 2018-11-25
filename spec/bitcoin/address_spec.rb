require 'spec_helper'

RSpec.describe Bitcoin::Address do
  let(:k){ PrivateKey.new 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725 }
  let(:public_key){ PublicKey.from_pk k }

  describe 'mainnet' do
    let(:address){ Bitcoin::Address.new public_key, testnet: false }

    it 'p2pkh' do
      expect(address.p2pkh).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
      expect(address.to_s).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
    end
    it 'p2sh' do
      expect(address.p2sh).to eq '3Q3zY87DrUmE371Grgc7bsDiVPqpu4mN1f'
    end
  end

  describe 'testnet' do
    let(:address){ Bitcoin::Address.new public_key }

    it 'p2pkh' do
      expect(address.p2pkh).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
      expect(address.to_s).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
    end
    it 'p2sh' do
      expect(address.p2sh).to eq '2NFcCbs3FTwGaEtdpXpDzDpCyhk3znhQzzo'
    end
  end
end
