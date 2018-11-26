require 'spec_helper'

RSpec.describe Cryptos::PublicKey do
  let(:k){ Cryptos::PrivateKey.new 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725 }
  let(:public_key){ Cryptos::PublicKey.new k }

  it 'compressed' do
    expect(public_key.sec).to eq '0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352'
  end
end
