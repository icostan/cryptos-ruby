require 'spec_helper'

RSpec.describe Litecoin do
  let(:cli) { Connectors::Cli.new 'litecoin-cli' }

  describe 'spend' do
    let(:private_key) { PrivateKey.generate }
    let(:public_key) { PublicKey.from_pk private_key }
    let(:address) { Litecoin::Address.from_pk public_key }
    let(:destination_address) {
      Litecoin::Address.from_pk PublicKey.from_pk PrivateKey.generate
    }

    before do
      cli.run "importaddress #{destination_address} dst", run_mode: :system
      cli.run "importaddress #{address} src", run_mode: :system
      cli.run "generatetoaddress 101 #{address}", run_mode: :inline
    end

    it 'address' do
      output = cli.run "listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
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
      cli.run "sendrawtransaction #{rawtx}", run_mode: :system

      cli.run "generate 1"

      output = cli.run "getreceivedbyaddress #{destination_address}"
      expect(output).to include '1.00000000'
    end
  end
end
