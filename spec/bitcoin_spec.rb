require 'tmpdir'

RSpec.describe Bitcoin do
  let(:cli) { Connectors::Cli.new }

  let(:private_key) { PrivateKey.generate }
  let(:public_key) { PublicKey.from_pk private_key }
  let(:address) { Bitcoin::Address.from_pk public_key }
  let(:destination_address) {
    Bitcoin::Address.from_pk PublicKey.from_pk PrivateKey.generate
  }

  before do
    am_i_rich? address
    am_i_rich? destination_address
    cli.run "importaddress #{destination_address} dst", run_mode: :system
    cli.run "importaddress #{address} src", run_mode: :system
    cli.run "generatetoaddress 101 #{address}", run_mode: :inline
  end

  it 'spend coinbase' do
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

    generate_and_check cli, destination_address, '1.00000000'
  end

  describe 'nLocktime' do
    it 'in number of blocks' do
      block_count = cli.run "getblockcount"
      result = cli.run "listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
      input = Input.from_utxo result, sequence: 0

      output_script = Bitcoin::Script.for_address destination_address
      output = Output.new 100_000_000, output_script

      change_value = input.value - output.value - 10_000
      change_script = Bitcoin::Script.for_address address
      change = Output.new change_value, change_script

      lock_script = Bitcoin::Script.for_address address
      t = Transaction.new 1, [input], [output, change], block_count.to_i + 1
      rawtx = t.sign private_key, public_key, lock_script

      result = cli.run "testmempoolaccept '[\"#{rawtx}\"]'"
      expect(result).to include 'non-final'

      generate_and_check cli, destination_address, '0.00000000'

      cli.run "sendrawtransaction #{rawtx}", run_mode: :system
      generate_and_check cli, destination_address, '1.00000000'
    end
    it 'in unix timestamp' do
      result = cli.run "listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
      input = Input.from_utxo result, sequence: 0

      output_script = Bitcoin::Script.for_address destination_address
      output = Output.new 100_000_000, output_script

      change_value = input.value - output.value - 10_000
      change_script = Bitcoin::Script.for_address address
      change = Output.new change_value, change_script

      lock_script = Bitcoin::Script.for_address address
      t = Transaction.new 1, [input], [output, change], Time.now.utc.to_i + 5
      rawtx = t.sign private_key, public_key, lock_script

      cli.run "sendrawtransaction #{rawtx}", run_mode: :system
      generate_and_check cli, destination_address, '0.00000000'

      sleep 5
      generate_and_check cli, destination_address, '1.00000000'
    end
  end

  def generate_and_check(cli, address, amount)
    cli.run 'generate 1'
    result = cli.run "getreceivedbyaddress #{address}"
    expect(result).to include amount
  end
end
