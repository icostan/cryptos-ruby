require 'json'
require 'tmpdir'

RSpec.describe 'Bitcoin' do
  def run_command(cmd, v: false, run_mode: :inline)
    puts "==> #{cmd}"
    case run_mode
    when :inline
      output = `#{cmd}`
      puts output if v
      output
    when :system
      success = system cmd
      expect(success).to be_truthy
      success
    when :daemon
      pid = spawn cmd
      sleep 10
      pid
    else
      raise "dont know how to run #{run_mode}"
    end
  end

  describe 'spend' do
    let(:private_key) {
      # 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
      bitcoin_new_private_key
    }
    let(:public_key) { bitcoin_new_public_key private_key }
    let(:address) { bitcoin_new_address public_key }
    let(:destination_address) { 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4' }

    before do
      run_command "bitcoin-cli -regtest importaddress #{destination_address} dst", run_mode: :system
      run_command "bitcoin-cli -regtest importaddress #{address} src", run_mode: :system
      run_command "bitcoin-cli -regtest generatetoaddress 101 #{address}", run_mode: :inline
    end

    it 'spend address' do
      output = run_command "bitcoin-cli -regtest listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
      input = Bitcoin.input_from_utxo output

      output_script = bitcoin_script destination_address
      output = Output.new 100_000_000, output_script

      change_value = input.value - output.value - 10_000
      change_script = bitcoin_script address
      change = Output.new change_value, change_script

      lock_script = bitcoin_script address
      t = Transaction.new 1, [input], [output, change], 0
      rawtx = t.sign private_key, public_key, lock_script
      run_command "bitcoin-cli -regtest sendrawtransaction #{rawtx}", run_mode: :system

      run_command 'bitcoin-cli -regtest generate 1'

      output = run_command "bitcoin-cli -regtest getreceivedbyaddress #{destination_address}"
      expect(output).to include '1.00000000'
    end
  end

  it 'generate address' do
    k = 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
    public_key = bitcoin_new_public_key k
    expect(public_key).to eq '0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352'
    address = bitcoin_new_address public_key, '00'
    expect(address).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
    address = bitcoin_new_address public_key, '6f'
    expect(address).to eq 'n3svudhm7bt6j3nTT9uu1A57Cs9pKK3iXW'
  end

  describe Der do
    it '#initialize' do
      der = Der.new r: 'r'
      expect(der.r).to eq 'r'
      expect(der.s).to be_nil
      expect(der.sighash_type).to eq 0x01
    end

    it '#serialize' do
      signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
      der = Der.new r: 0x884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb,
                    s: 0x4b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e3813
      expect(der.serialize).to eq signature
    end

    it '.parse' do
      signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
      der = Der.parse signature
      expect(der.der).to eq 0x30
      expect(der.length).to eq 0x45
      expect(der.sighash_type).to eq 0x01
    end
  end

  describe Transaction do
    it '#serialize' do
      input = Input.new 0, '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0
      t = Transaction.new 1, [input], [], 0
      expect(t.serialize).to eq '0100000001b3807042c92f449bbf79b33ca59d7dfec7f4cc71096704a9c526dddf496ee0970000000000ffffffff0000000000'
    end

    it '#hash' do
      input = Input.new 0, '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0
      t = Transaction.new 1, [input], [], 0
      expect(t.hash).to eq '0021a5a6876307b6093da76ab62e9487ad9a5a32b8a39cf6263064990e9253bb'
    end

    it '#signature_hash' do
      input = Input.new 0, '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0
      input.unlock_script = 'OP_DUP OP_HASH160 88350574280395ad2c3e2ee20e322073d94e5e40 OP_EQUALVERIFY OP_CHECKSIG'
      t = Transaction.new 1, [input], [], 0
      bytes_string = t.signature_hash
      hex = t.to_hex bytes_string
      expect(hex).to eq 'f89572635651b2e4f89778350616989183c98d1a721c911324bf9f17a0cf5bf0'
    end

    xit '#endorsement' do
      private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
      public_key = 0x03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1
      lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
      input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
      output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
      t = Transaction.new 1, [input], [output], 0
      endorsement = t.endorsement private_key, public_key, lock_script
      expect(endorsement).to eq '3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101'
    end

    xit '#sign' do
      private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
      public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
      lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
      input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
      output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
      t = Transaction.new 1, [input], [output], 0
      hex = t.sign private_key, public_key, lock_script
      # puts hex
      h = '010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b4830450221008a0637decccbd0c48c5f36d56cd3853db53eb2f04a87e44c14cc7f14cfea54cf02208061e91418cc8e95d732618966648878733ed52b58765b49111e60da2c068db8012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000'
      # expect(hex).to eq h
    end
  end

  describe 'bitcoin' do
    it 'bitcoin_base58_encode' do
      result = bitcoin_base58_encode '00f54a5851e9372b87810a8e60cdd2e7cfd80b6e31c7f18fe8'
      expect(result).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
    end
    it 'bitcoin_base58_decode' do
      result = bitcoin_base58_decode '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
      expect(result).to eq '00f54a5851e9372b87810a8e60cdd2e7cfd80b6e31c7f18fe8'
    end
    it 'bitcoin_address_decode' do
      result = bitcoin_address_decode '2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn'
      expect(result).to eq 'f81498040e79014455a5e8f7bd39bce5428121d3'
    end
  end
end
