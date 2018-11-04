require 'spec_helper'

RSpec.describe Litecoin do
  describe 'spend' do
    let(:private_key) {
      bitcoin_new_private_key
    }
    let(:public_key) { bitcoin_new_public_key private_key }
    let(:address) { Litecoin::Address.from_pk public_key }
    let(:destination_address) {
      Litecoin::Address.from_pk bitcoin_new_public_key bitcoin_new_private_key
    }
    let(:cli) { 'litecoin-cli' }

    before do
      run_command "#{cli} -regtest importaddress #{destination_address} dst", run_mode: :system
      run_command "#{cli} -regtest importaddress #{address} src", run_mode: :system
      run_command "#{cli} -regtest generatetoaddress 101 #{address}", run_mode: :inline
    end

    it 'address' do
      output = run_command "#{cli} -regtest listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
      input = Input.from_utxo output
      # puts input.inspect

      output_script = bitcoin_script destination_address
      output = Output.new 100_000_000, output_script

      change_value = input.value - output.value - 10_000
      change_script = bitcoin_script address
      change = Output.new change_value, change_script

      lock_script = bitcoin_script address
      t = Transaction.new 1, [input], [output, change], 0
      rawtx = t.sign private_key, public_key, lock_script
      run_command "#{cli} -regtest sendrawtransaction #{rawtx}", run_mode: :system

      run_command "#{cli} -regtest generate 1"

      output = run_command "#{cli} -regtest getreceivedbyaddress #{destination_address}"
      expect(output).to include '1.00000000'
    end
  end
end
