require 'spec_helper'

RSpec.describe Cryptos::Script do
  describe 'multisig' do
    let(:private_key1){ Cryptos::PrivateKey.new 12755832826740707222921951597071687965583213953157887598355879400865076022930 }
    let(:private_key2){ Cryptos::PrivateKey.new 64401238684488580329918508657069783716079536189346879599652256679437103753779 }
    let(:public_key1){ Cryptos::PublicKey.new private_key1 }
    let(:public_key2){ Cryptos::PublicKey.new private_key2 }
    let(:address1){ Cryptos::Address.new public_key1 }
    let(:address2){ Cryptos::Address.new public_key2 }

    it '#to_hex' do
      script = Cryptos::Script.multisig address1, address2
      expect(script.to_hex).to eq '522103abc62b9693416ec396ec987b7335f7d717b289a877094646828c49707a5afc83210217b1b414bd56d4bc3576fb40f7228b973b1bb244a26e59d3c106864b296d672f52ae'
    end
    it '#to_hash160' do
      script = Cryptos::Script.multisig address1, address2
      expect(script.to_hash160).to eq 'e3c5c4635de1d0cb23a3206f01a84c0170cfbf5d'
    end
  end
end
