module Cryptos
  Output = Struct.new :value, :script_pubkey do
    def self.p2pkh(address, amount)
      output_script = Cryptos::Script.for_address address
      Output.new amount, output_script
    end

    def self.multisig(a1, a2, amount)
      redeem_script = Cryptos::Script.multisig a1, a2
      Output.new amount, Cryptos::Script.p2sh(redeem_script.to_hash160)
    end

    def self.p2pkh_change(address, input, output, fee = 10_000)
      change_value = input.value - output.value - fee
      Output.p2pkh address, change_value
    end

    def serialize
      script_hex = script_to_hex(script_pubkey)
      long_to_hex(value) + byte_to_hex(hex_size(script_hex)) + script_hex
    end
  end
end
