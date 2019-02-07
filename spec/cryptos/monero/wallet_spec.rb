require 'spec_helper'

RSpec.describe Cryptos::Monero::Wallet do
  let(:mnemonic) { 'vinegar talent sorry hybrid ultimate template nimbly jukebox axes inactive veered toenail pride plotting chrome victim agnostic science bailed paddles wounded peaches king laptop king' }
  let(:seed) { '6ee02ef8647856f4080882a1ec4fabee19ec047ca24d3abb13c0ce589a46f702' }
  subject do
    Cryptos::Monero::Wallet.new seed
  end

  it '.from_mnemonic' do
    wallet = Cryptos::Monero::Wallet.from_mnemonic mnemonic
    expect(wallet.seed).to eq seed
  end

  it '#to_mnemonic' do
    wallet = Cryptos::Monero::Wallet.new seed
    expect(wallet.to_mnemonic).to eq mnemonic
  end

  it '#to_private_spend_key' do
    private_spend_key = subject.private_spend_key
    expect(private_spend_key.value).to eq 1341524205595389594312687854960107116555340486708078533906470082005332582510
    expect(private_spend_key.to_hex).to eq seed
  end
end
