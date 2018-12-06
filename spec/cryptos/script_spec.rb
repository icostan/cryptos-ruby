require 'spec_helper'

RSpec.describe Cryptos::Script do
  include Cryptos::Utils::Hashes

  let(:private_key1){ Cryptos::PrivateKey.new 12755832826740707222921951597071687965583213953157887598355879400865076022930 }
  let(:private_key2){ Cryptos::PrivateKey.new 64401238684488580329918508657069783716079536189346879599652256679437103753779 }
  let(:public_key1){ Cryptos::PublicKey.new private_key1 }
  let(:public_key2){ Cryptos::PublicKey.new private_key2 }
  let(:address1){ Cryptos::Address.new public_key1 }
  let(:address2){ Cryptos::Address.new public_key2 }

  describe 'atomic swap' do
    let(:secret){ sha256 'UNSECURE' }
    let(:secret_hash){ ripemd160 secret }
    let(:script){ Cryptos::Script.swap secret_hash, address1, 1544006911, address2 }

    it '#to_asm' do
      expect(script.to_asm).to eq 'OP_IF OP_RIPEMD160 7529b652d57457472ad2e935a0e9a34f598159ae OP_EQUALVERIFY OP_DUP OP_HASH160 efb416fb0b026d74ab80fb851a381998ff5036a4 OP_ELSE 1544006911 OP_CHECKLOCKTIMEVERIFY OP_DROP OP_DUP OP_HASH160 d480466b5d9cf97c1c6dcfe85e6e9520b5a8b6c8 OP_ENDIF OP_EQUALVERIFY OP_CHECKSIG'
    end
    it '#to_hex' do
      expect(script.to_hex).to eq '63a6147529b652d57457472ad2e935a0e9a34f598159ae8876a914efb416fb0b026d74ab80fb851a381998ff5036a467051544006911b17576a914d480466b5d9cf97c1c6dcfe85e6e9520b5a8b6c86888ac'
    end
    it '#size' do
      expect(script.size).to eq 82
    end
  end

  describe 'multisig' do
    let(:script){ Cryptos::Script.multisig address1, address2 }

    it '#to_hex' do
      expect(script.to_hex).to eq '522103abc62b9693416ec396ec987b7335f7d717b289a877094646828c49707a5afc83210217b1b414bd56d4bc3576fb40f7228b973b1bb244a26e59d3c106864b296d672f52ae'
    end
    it '#to_hash160' do
      expect(script.to_hash160).to eq 'e3c5c4635de1d0cb23a3206f01a84c0170cfbf5d'
    end
  end
end
