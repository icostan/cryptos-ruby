module Cryptos
  Transaction = Struct.new :version, :inputs, :outputs, :locktime do
    include Utils::Hexas, Utils::Hashes

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
      hex_to_little sha256(sha256(serialize))
    end

    def signature_hash(script_pubkey = nil, sighash_type = 0x01)
      inputs.first.script_sig = script_pubkey if script_pubkey
      hash = sha256(sha256(serialize + int_to_hex(sighash_type)))
      [hash].pack('H*')
    end

    def sign(private_key, public_key, script_pubkey, sighash_type = 0x01)
      bytes_string = signature_hash script_pubkey, sighash_type
      r, s = ecdsa_sign private_key.value, bytes_string
      der = Cryptos::Der.new r: r, s: s
      inputs.first.script_sig = Script.sig_pubkey(der, public_key)
      serialize
    end

    def sign_input(index, address, sighash_type = 0x01)
      # TODO: get script_pubkey from input?
      script_pubkey = Cryptos::Script.p2pkh address
      bytes_string = signature_hash script_pubkey, sighash_type

      r, s = ecdsa_sign address.public_key.private_key.value, bytes_string
      der = Cryptos::Der.new r: r, s: s
      inputs[index].script_sig = Script.sig_pubkey der, address.public_key

      serialize
    end

    def multi_sign_input(index, address1, address2, sighash_type = 0x01)
      redeem_script = Cryptos::Script.multisig address1, address2
      bytes_string = signature_hash redeem_script, sighash_type

      r, s = ecdsa_sign address1.public_key.private_key.value, bytes_string
      der1 = Cryptos::Der.new r: r, s: s
      r, s = ecdsa_sign address2.public_key.private_key.value, bytes_string
      der2 = Cryptos::Der.new r: r, s: s
      inputs[index].script_sig = Script.sig_multisig der1, der2, redeem_script

      serialize
    end

    def to_s
      inputs.to_s + outputs.to_s
    end
  end
end
