module Cryptos
  Transaction = Struct.new :version, :inputs, :outputs, :locktime do
    def self.from_ioc(input, output, change, version: 1, locktime: 0)
      new version, [input], [output, change], locktime
    end
    def serialize
      inputs_hex = inputs.map(&:serialize).join
      outputs_hex = outputs.map(&:serialize).join
      int_to_hex(version) + byte_to_hex(inputs.size) + inputs_hex +
        byte_to_hex(outputs.size) + outputs_hex + int_to_hex(locktime)
    end

    def hash
      hash_to_hex sha256(sha256(serialize))
    end

    def signature_hash(lock_script = nil, sighash_type = 0x01)
      inputs.first.unlock_script = lock_script if lock_script
      hash = sha256(sha256(serialize + int_to_hex(sighash_type)))
      [hash].pack('H*')
    end

    def sign(private_key, public_key, lock_script, sighash_type = 0x01)
      bytes_string = signature_hash lock_script, sighash_type
      r, s = ecdsa_sign private_key.value, bytes_string
      der = Der.new r: r, s: s
      inputs.first.unlock_script = "#{der.serialize} #{public_key.compressed}"
      serialize
    end
    def sign_input(index, address, sighash_type = 0x01)
      # TODO: get lock_script from input?
      lock_script = Cryptos::Script.for_address address
      bytes_string = signature_hash lock_script, sighash_type
      r, s = ecdsa_sign address.public_key.private_key.value, bytes_string
      der = Der.new r: r, s: s
      inputs[index].unlock_script = "#{der.serialize} #{address.public_key.compressed}"
      serialize
    end
    def to_s
      "Transaction[inputs:#{inputs.map &:value}, outputs:#{outputs.map &:value}"
    end
  end
end
