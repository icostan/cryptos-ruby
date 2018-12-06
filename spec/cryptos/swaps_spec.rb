require 'spec_helper'

RSpec.describe 'Swaps' do
  include Cryptos::Utils::Hashes

  # signature
  # pubkey
  # secret
  # 1
  # redeem script

  # OP_IF
  #   OP_RIPEMD160 29c36b8dd380e0426bdc1d834e74a630bfd5d111 OP_EQUALVERIFY
  #   OP_DUP OP_HASH160 ebcf822c4a2cdb5f6a6b9c4a59b74d66461da581
  # OP_ELSE
  #   1505568983 OP_CHECKLOCKTIMEVERIFY OP_DROP
  #   OP_DUP OP_HASH160 06fb26221375b1cbe2c17c14f1bc2510b9f8f8ff
  # OP_ENDIF
  # OP_EQUALVERIFY OP_CHECKSIG

  before :all do
    @private_key = Cryptos::PrivateKey.generate
    @public_key = Cryptos::PublicKey.new @private_key

    @btc_cli = Cryptos::Connectors::Cli.new
    @btc_from_address = Cryptos::Bitcoin::Address.new @public_key
    @btc_from_address.import @btc_cli
    @btc_cli.generate_to_address @btc_from_address, blocks: 101

    @ltc_cli = Cryptos::Connectors::Cli.new program: 'litecoin-cli'
    @ltc_from_address = Cryptos::Litecoin::Address.new @public_key
    @ltc_from_address.import @ltc_cli
    @ltc_cli.generate_to_address @ltc_from_address, blocks: 101
  end

  describe 'BTCLTC' do
    let(:public_key) { Cryptos::PublicKey.new Cryptos::PrivateKey.generate }
    let(:btc_to_address) { Cryptos::Bitcoin::Address.new public_key }
    let(:ltc_to_address) { Cryptos::Litecoin::Address.new public_key }

    before do
      btc_to_address.import @btc_cli
      ltc_to_address.import @ltc_cli
    end

    it 'contract' do
      secret = sha256 'UNSECURE'
      secret_hash = ripemd160 secret

      btc_locktime = Time.now.to_i + 60
      ltc_locktime = Time.now.to_i + 30

      # funding BTC
      input = Cryptos::Input.from_utxo @btc_cli, @btc_from_address
      output = Cryptos::Output.atomic_swap secret_hash, btc_to_address, btc_locktime, @btc_from_address, 100_000_000
      change = Cryptos::Output.p2pkh_change @btc_from_address, input, output
      btc_transaction = Cryptos::Transaction.from_ioc input, output, change
      btc_transaction.sign_single_input @btc_from_address
      btc_transaction.broadcast @btc_cli
      @btc_cli.generate

      # funding LTC
      input = Cryptos::Input.from_utxo @ltc_cli, @ltc_from_address
      output = Cryptos::Output.atomic_swap secret_hash, ltc_to_address, ltc_locktime, @ltc_from_address, 1_000_000_000
      change = Cryptos::Output.p2pkh_change @ltc_from_address, input, output
      ltc_transaction = Cryptos::Transaction.from_ioc input, output, change
      ltc_transaction.sign_single_input @ltc_from_address
      ltc_transaction.broadcast @ltc_cli
      @ltc_cli.generate

      # redeem LTC
      input = Cryptos::Input.from_tx ltc_transaction
      output = Cryptos::Output.p2pkh ltc_to_address, 999_000_000
      change = Cryptos::Output.p2pkh_change @ltc_from_address, input, output
      transaction = Cryptos::Transaction.from_ioc input, output, change
      transaction.sign_atomic_swap secret, secret_hash, ltc_to_address, ltc_locktime, @ltc_from_address
      transaction.broadcast @ltc_cli
      generate_and_check @ltc_cli, ltc_to_address, '9.99000000'

      # redeem BTC
      input = Cryptos::Input.from_tx btc_transaction
      output = Cryptos::Output.p2pkh btc_to_address, 99_000_000
      change = Cryptos::Output.p2pkh_change @btc_from_address, input, output
      transaction = Cryptos::Transaction.from_ioc input, output, change
      transaction.sign_atomic_swap secret, secret_hash, btc_to_address, btc_locktime, @btc_from_address
      transaction.broadcast @btc_cli
      generate_and_check @btc_cli, btc_to_address, '0.99000000'
    end
  end
end
