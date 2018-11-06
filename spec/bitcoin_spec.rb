require 'tmpdir'

RSpec.describe Bitcoin do
  let(:private_key) {
    PrivateKey.generate
  }
  let(:public_key) { PublicKey.from_pk private_key }
  let(:address) { Bitcoin::Address.from_pk public_key }
  let(:destination_address) {
    Bitcoin::Address.from_pk PublicKey.from_pk PrivateKey.generate
  }

  before do
    am_i_rich? address
    am_i_rich? destination_address
    run_command "bitcoin-cli -regtest importaddress #{destination_address} dst", run_mode: :system
    run_command "bitcoin-cli -regtest importaddress #{address} src", run_mode: :system
    run_command "bitcoin-cli -regtest generatetoaddress 101 #{address}", run_mode: :inline
  end

  it 'spend coinbase' do
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

  it 'spend nLocktime' do
    block_count = run_command "bitcoin-cli -regtest getblockcount"
    result = run_command "bitcoin-cli -regtest listunspent 1 9999 \"[\\\"#{address}\\\"]\"", v: false
    input = Input.from_utxo result, sequence: 0

    output_script = Bitcoin::Script.for_address destination_address
    output = Output.new 100_000_000, output_script

    change_value = input.value - output.value - 10_000
    change_script = Bitcoin::Script.for_address address
    change = Output.new change_value, change_script

    lock_script = Bitcoin::Script.for_address address
    t = Transaction.new 1, [input], [output, change], block_count.to_i + 1
    rawtx = t.sign private_key, public_key, lock_script

    result = run_command "bitcoin-cli -regtest testmempoolaccept '[\"#{rawtx}\"]'"
    expect(result).to include 'non-final'

    run_command 'bitcoin-cli -regtest generate 1'
    result = run_command "bitcoin-cli -regtest getreceivedbyaddress #{destination_address}"
    expect(result).to include '0.00000000'

    run_command "bitcoin-cli -regtest sendrawtransaction #{rawtx}", run_mode: :system
    run_command 'bitcoin-cli -regtest generate 1'
    result = run_command "bitcoin-cli -regtest getreceivedbyaddress #{destination_address}"
    expect(result).to include '1.00000000'
  end
end
