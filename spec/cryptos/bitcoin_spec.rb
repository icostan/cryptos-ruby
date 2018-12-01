# require 'tmpdir'

RSpec.describe Cryptos::Bitcoin do
  before :all do
    @cli = Cryptos::Connectors::Cli.new
    @private_key = Cryptos::PrivateKey.generate
    @public_key = Cryptos::PublicKey.new @private_key
    @from_address = Cryptos::Bitcoin::Address.new @public_key
    @from_address.import @cli
    @cli.generate_to_address @from_address, blocks: 105
  end

  it 'spend coinbase' do
    to_address = Cryptos::Bitcoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate
    to_address.import @cli

    input = Cryptos::Input.from_utxo @cli, @from_address
    output = Cryptos::Output.p2pkh to_address, 123_456_789
    change = Cryptos::Output.p2pkh_change @from_address, input, output

    transaction = Cryptos::Transaction.from_ioc input, output, change
    transaction.sign_single_input @from_address
    transaction.broadcast @cli

    @cli.generate blocks: 1
    result = @cli.get_received_by_address to_address
    expect(result).to include '1.23456789'
  end

  describe 'nLocktime' do
    let(:to_address) { Cryptos::Bitcoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate }

    before do
      to_address.import @cli
    end

    it 'as number of blocks' do
      input = Cryptos::Input.from_utxo @cli, @from_address, 1, sequence: 0
      output = Cryptos::Output.p2pkh to_address, 100_000_000
      change = Cryptos::Output.p2pkh_change @from_address, input, output

      locktime = @cli.get_block_count + 1
      transaction = Cryptos::Transaction.from_ioc input, output, change, locktime: locktime
      rawtx = transaction.sign_single_input @from_address

      result = @cli.test_raw_transaction rawtx
      expect(result).to include 'non-final'

      generate_and_check @cli, to_address, '0.00000000'

      @cli.send_raw_transaction rawtx
      generate_and_check @cli, to_address, '1.00000000'
    end

    it 'as unix timestamp' do
      input = Cryptos::Input.from_utxo @cli, @from_address, 2, sequence: 0
      output = Cryptos::Output.p2pkh to_address, 100_000_000
      change = Cryptos::Output.p2pkh_change @from_address, input, output

      transaction = Cryptos::Transaction.from_ioc input, output, change, locktime: Time.now.utc.to_i + 5
      rawtx = transaction.sign_single_input @from_address

      @cli.send_raw_transaction rawtx
      generate_and_check @cli, to_address, '0.00000000'

      sleep 6
      generate_and_check @cli, to_address, '1.00000000'
    end
  end
end
