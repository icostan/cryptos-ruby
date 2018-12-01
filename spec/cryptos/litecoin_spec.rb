require 'spec_helper'

RSpec.describe Cryptos::Litecoin do
  before :all do
    @cli = Cryptos::Connectors::Cli.new program: 'litecoin-cli'
    @private_key = Cryptos::PrivateKey.generate
    @public_key = Cryptos::PublicKey.new @private_key
    @from_address = Cryptos::Litecoin::Address.new @public_key
    @from_address.import @cli
    @cli.generate_to_address @from_address, blocks: 102
  end

  let(:to_address) { Cryptos::Litecoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate }
  before do
    to_address.import @cli
  end

  describe 'spend' do
    it 'coinbase' do
      input = Cryptos::Input.from_utxo @cli, @from_address
      output = Cryptos::Output.p2pkh to_address, 100_000_000
      change = Cryptos::Output.p2pkh_change @from_address, input, output
      transaction = Cryptos::Transaction.from_ioc input, output, change

      transaction.sign_single_input @from_address
      transaction.broadcast @cli
      generate_and_check @cli, to_address, '1.00000000'
    end
    describe 'multisig' do
      let(:to_address2) { Cryptos::Litecoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate }
      before do
        to_address2.import @cli
      end

      it 'hash script output' do
        # to multisig
        input = Cryptos::Input.from_utxo @cli, @from_address, 1
        output = Cryptos::Output.multisig to_address, to_address2, 1_000_000_000
        change = Cryptos::Output.p2pkh_change @from_address, input, output
        transaction = Cryptos::Transaction.from_ioc input, output, change
        transaction.sign_single_input @from_address
        transaction.broadcast @cli
        @cli.generate

        # spend multisig
        input = Cryptos::Input.from_tx transaction
        output = Cryptos::Output.p2pkh to_address, 500_000_000
        change = Cryptos::Output.p2pkh_change to_address2, input, output
        transaction = Cryptos::Transaction.from_ioc input, output, change

        transaction.multi_sign_input 0, to_address, to_address2
        transaction.broadcast @cli
        generate_and_check @cli, to_address, '5.00000000'
        generate_and_check @cli, to_address2, '4.99990000'
      end
    end
  end
end
