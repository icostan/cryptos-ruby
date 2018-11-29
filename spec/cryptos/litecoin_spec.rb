require 'spec_helper'

RSpec.describe Cryptos::Litecoin do
  before :all do
    @cli = Cryptos::Connectors::Cli.new program: 'litecoin-cli'
    @private_key = Cryptos::PrivateKey.generate
    @public_key = Cryptos::PublicKey.new @private_key
    @from_address = Cryptos::Litecoin::Address.new @public_key
    @cli.run "importaddress #{@from_address} src", run_mode: :system
    @cli.run "generatetoaddress 102 #{@from_address}", run_mode: :inline
    @utxos = @cli.run "listunspent 1 9999 \"[\\\"#{@from_address}\\\"]\"", v: false
  end

  let(:to_address) { Cryptos::Litecoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate }
  before do
    @cli.run "importaddress #{to_address} dst", run_mode: :system
  end

  describe 'spend' do
    it 'coinbase' do
      input = Cryptos::Input.from_utxo @utxos, 0
      output = Cryptos::Output.p2pkh to_address, 100_000_000
      change = Cryptos::Output.p2pkh_change @from_address, input, output
      transaction = Cryptos::Transaction.from_ioc input, output, change

      rawtx = transaction.sign_input 0, @from_address
      @cli.run "sendrawtransaction #{rawtx}", run_mode: :system
      generate_and_check @cli, to_address, '1.00000000'
    end
    describe 'multisig' do
      let(:to_address2) { Cryptos::Litecoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate }
      before do
        @cli.run "importaddress #{to_address2} dst2", run_mode: :system
      end

      it 'hash script output' do
        # to multisig
        input = Cryptos::Input.from_utxo @utxos, 1
        output = Cryptos::Output.multisig to_address, to_address2, 1_000_000_000
        change = Cryptos::Output.p2pkh_change @from_address, input, output
        transaction = Cryptos::Transaction.from_ioc input, output, change
        rawtx = transaction.sign_input 0, @from_address
        txid = @cli.run "sendrawtransaction #{rawtx}"
        @cli.run 'generate 1'

        # spend multisig
        input = Cryptos::Input.from_tx transaction
        output = Cryptos::Output.p2pkh to_address, 500_000_000
        change = Cryptos::Output.p2pkh_change to_address2, input, output
        transaction = Cryptos::Transaction.from_ioc input, output, change

        rawtx = transaction.multi_sign_input 0, to_address, to_address2
        @cli.run "sendrawtransaction #{rawtx}", run_mode: :system
        generate_and_check @cli, to_address, '5.00000000'
        generate_and_check @cli, to_address2, '4.99990000'
      end
    end
  end
end
