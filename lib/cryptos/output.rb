Output = Struct.new :value, :lock_script do
  def self.p2pkh(address, amount)
    output_script = Script.for_address address
    Output.new amount, output_script
  end
  def self.p2pkh_change(address, input, output, fee = 10_000)
    change_value = input.value - output.value - fee
    Output.p2pkh address, change_value
  end
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(value) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end
