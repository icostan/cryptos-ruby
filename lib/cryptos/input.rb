module Cryptos
  Input = Struct.new :value, :tx_hash, :index, :unlock_script, :sequence do
    def self.from_utxo(data, index = 0, options = {debug: false})
      utxo = JSON.parse(data)[index]
      puts utxo if options[:debug]
      txid = utxo['txid']
      vout = utxo['vout']
      amount = utxo['amount']
      sequence = options[:sequence] || 0xfffffffff
      Input.new amount * 10**8, txid, vout, sequence: sequence
    end
    def initialize(value, tx_hash, index, unlock_script: '', sequence: 0xfffffffff)
      super value, tx_hash, index, unlock_script, sequence
    end
    def serialize
      script_hex = script_to_hex(unlock_script)
      hash_to_hex(tx_hash) + int_to_hex(index) +
        byte_to_hex(hex_size(script_hex)) + script_hex + int_to_hex(sequence)
    end
  end
end
