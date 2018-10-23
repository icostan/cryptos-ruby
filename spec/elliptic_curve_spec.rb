RSpec.describe 'EllipticCurve' do
  describe 'ecdsa_sign and verify' do
    before do
      message = 'Hello World!'
      @private_key = 5124534118363973067682110154994366664263350313713476914759747396381294262665
      @px, @py = ec_multiply @private_key, EC_Gx, EC_Gy, EC_p
      @temp_key = 8170412689086572914872624726984617755309377628698418075870043184004257040259
      @digest = Digest::SHA256.digest(message)
    end

    it 'with ECDSA gem' do
      require 'ecdsa'
      group = ECDSA::Group::Secp256k1
      public_key = ECDSA::Point.new group, @px, @py

      signature = ECDSA.sign(group, @private_key, @digest, @temp_key)
      valid = ECDSA.valid_signature?(public_key, @digest, signature)
      expect(valid).to be_truthy
    end

    describe 'with cryptocrafts' do
      it 'same temp key' do
        r, s = ecdsa_sign(@private_key, @digest, @temp_key)
        valid = ecdsa_verify?(@px, @py, @digest, [r, s])
        expect(valid).to be_truthy
      end
      it 'new temp key' do
        r, s = ecdsa_sign(@private_key, @digest)
        valid = ecdsa_verify?(@px, @py, @digest, [r, s])
        expect(valid).to be_truthy
      end
    end

    describe 'transaction' do
      it 'signature hash' do
        private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
        px, py = ec_multiply private_key, EC_Gx, EC_Gy, EC_p
        lock_script = bitcoin_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
        input = Input.new 0, 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1
        output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
        t = Transaction.new 1, [input], [output], 0
        hash = t.signature_hash lock_script
        hash_bytes = [hash].pack('H*')
        r, s = ecdsa_sign private_key, hash_bytes
        valid = ecdsa_verify? px, py, hash_bytes, [r, s]
        expect(valid).to be_truthy
      end
    end
  end
end
