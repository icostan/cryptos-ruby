require 'spec_helper'

RSpec.describe Litecoin do
  before :all do
    @cli = Connectors::Cli.new 'litecoin-cli'
    @private_key = PrivateKey.generate
    @public_key = PublicKey.from_pk @private_key
    @from_address = Litecoin::Address.new @public_key
    @cli.run "importaddress #{@from_address} src", run_mode: :system
    @cli.run "generatetoaddress 105 #{@from_address}", run_mode: :inline
    @utxos = @cli.run "listunspent 1 9999 \"[\\\"#{@from_address}\\\"]\"", v: false
  end

  let(:to_address) { Litecoin::Address.new PublicKey.from_pk PrivateKey.generate }
  before do
    @cli.run "importaddress #{to_address} dst", run_mode: :system
  end

  describe 'spend' do
    it 'coinbase' do
      input = Input.from_utxo @utxos, 0
      output = Output.p2pkh to_address, 100_000_000
      change = Output.p2pkh_change @from_address, input, output
      transaction = Transaction.from_ioc input, output, change

      rawtx = transaction.sign_input 0, @from_address
      @cli.run "sendrawtransaction #{rawtx}", run_mode: :system
      generate_and_check @cli, to_address, '1.00000000'
    end
    it 'multisig'
  end
end
