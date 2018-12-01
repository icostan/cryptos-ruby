module Cryptos
  Input = Struct.new :value, :tx_hash, :index, :script_sig, :sequence do
    include Utils::Hexas, Utils::Hashes

    def self.from_utxo(cli, address, index = 0, options = {debug: false})
      utxos = cli.list_unspent address
      utxo = JSON.parse(utxos)[index]
      puts utxo if options[:debug]
      txid = utxo['txid']
      vout = utxo['vout']
      amount = utxo['amount']
      sequence = options[:sequence] || 0xfffffffff
      Input.new amount * 10**8, txid, vout, sequence: sequence
    end

    def self.from_tx(transaction, index = 0, options = {})
      amount = transaction.outputs[index].value
      sequence = options[:sequence] || 0xfffffffff
      Input.new amount, transaction.hash, index, sequence: sequence
    end

    def initialize(value, tx_hash, index, script_sig: nil, sequence: 0xfffffffff)
      super value, tx_hash, index, script_sig, sequence
    end

    def serialize
      script_hex = script_sig ? script_sig.to_hex : ''
      hex_to_little(tx_hash) + int_to_hex(index) +
        byte_to_hex(hex_size(script_hex)) + script_hex + int_to_hex(sequence)
    end
  end
end
