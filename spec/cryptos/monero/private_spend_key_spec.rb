require 'spec_helper'

RSpec.describe Cryptos::Monero::PrivateSpendKey do
  subject do
    Cryptos::Monero::PrivateSpendKey.new 1341524205595389594312687854960107116555340486708078533906470082005332582510
  end

  it '#to_hex' do
    expect(subject.to_hex).to eq '6ee02ef8647856f4080882a1ec4fabee19ec047ca24d3abb13c0ce589a46f702'
  end

  it '#private_view_key' do
    expect(subject.private_view_key.to_hex).to eq 'fba03c096736c326b072fe44fc5c2868009986fb7e89e64bfd52f071d7e9b307'
    expect(subject.private_view_key.value).to eq 3484069479964683743232385990724912488542898907525657757969450137450809434363
  end
end
