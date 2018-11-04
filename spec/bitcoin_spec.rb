require 'tmpdir'

RSpec.describe Bitcoin do
  describe 'spend' do
    let(:private_key) {
      # 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
      PrivateKey.generate
    }
    let(:public_key) { PublicKey.from_pk private_key }
    let(:address) { Bitcoin::Address.from_pk public_key }
    let(:destination_address) {
      # 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
      Bitcoin::Address.from_pk PublicKey.from_pk PrivateKey.generate
    }

    before do
      run_command "bitcoin-cli -regtest importaddress #{destination_address} dst", run_mode: :system
      run_command "bitcoin-cli -regtest importaddress #{address} src", run_mode: :system
      run_command "bitcoin-cli -regtest generatetoaddress 101 #{address}", run_mode: :inline
    end

    it 'address' do
      output = run_command "bitcoin-cli -regtest listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
      input = Input.from_utxo output
      # puts input.inspect

      output_script = Bitcoin::Script.for_address destination_address
      output = Output.new 100_000_000, output_script

      change_value = input.value - output.value - 10_000
      change_script = Bitcoin::Script.for_address address
      change = Output.new change_value, change_script

      lock_script = Bitcoin::Script.for_address address
      t = Transaction.new 1, [input], [output, change], 0
      rawtx = t.sign private_key, public_key, lock_script
      run_command "bitcoin-cli -regtest sendrawtransaction #{rawtx}", run_mode: :system

      run_command 'bitcoin-cli -regtest generate 1'

      output = run_command "bitcoin-cli -regtest getreceivedbyaddress #{destination_address}"
      expect(output).to include '1.00000000'
    end
  end
end
