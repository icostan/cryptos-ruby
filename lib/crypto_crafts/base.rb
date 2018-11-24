require 'json'
require 'digest'

class Struct
  OPCODES = {
    'OP_DUP' =>  0x76,
    'OP_HASH160' =>  0xA9,
    'OP_EQUAL' =>  0x87,
    'OP_EQUALVERIFY' =>  0x88,
    'OP_CHECKSIG' =>  0xAC
  }.freeze

  def opcode(token)
    raise "opcode #{token} not found" unless OPCODES.include?(token)
    OPCODES[token].to_s 16
  end

  def data(token)
    bin_size = hex_size token
    # TODO: data size is defined as 1-9 bytes
    byte_to_hex(bin_size) + token
  end

  def hex_size(hex)
    [hex].pack('H*').size
  end

  def to_hex(binary_bytes)
    binary_bytes.unpack('H*').first
  end

  def hash_to_hex(value)
    to_hex [value].pack('H*').reverse
  end

  def int_to_hex(value)
    to_hex [value].pack('V')
  end

  def byte_to_hex(value)
    to_hex [value].pack('C')
  end

  def bytes_to_hex(bytes)
    to_hex bytes.pack('C*')
  end

  def long_to_hex(value)
    to_hex [value].pack('Q<')
  end

  def script_to_hex(script_string)
    script_string.split.map { |token| token.start_with?('OP') ? opcode(token) : data(token) }.join
  end

  def sha256(hex)
    Digest::SHA256.hexdigest([hex].pack('H*'))
  end
end

def bytes_to_bignum(bytes_string)
  bytes_string.bytes.reduce { |n, b| (n << 8) + b }
end

def bignum_to_bytes(n, length=nil, stringify=true)
  a = []
  while n > 0
    a << (n & 0xFF)
    n >>= 8
  end
  a.fill 0x00, a.length, length - a.length if length
  bytes = a.reverse
  stringify ? bytes.pack('C*') : bytes
end

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

Output = Struct.new :value, :lock_script do
  def self.p2pkh(address, amount)
    output_script = Bitcoin::Script.for_address address
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
    lock_script = Bitcoin::Script.for_address address
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

Der = Struct.new :der, :length, :ri, :rl, :r, :si, :sl, :s, :sighash_type do
  def initialize(der: 0x30, length: 0x44, ri: 0x02, rl: 0x20, r: nil, si: 0x02, sl: 0x20, s: nil, sighash_type: 0x01)
    super der, length, ri, rl, r, si, sl, s, sighash_type
  end

  def serialize
    r_bytes = bignum_to_bytes(r, 32, false)
    if r_bytes.first & 0x80 == 128
      r_bytes = [0x00] + r_bytes
      self.length += 1
      self.rl += 1
    end
    byte_to_hex(der) + byte_to_hex(length) +
      byte_to_hex(ri) + byte_to_hex(rl) + bytes_to_hex(r_bytes) +
      byte_to_hex(si) + byte_to_hex(sl) + to_hex(bignum_to_bytes(s, 32)) +
      byte_to_hex(sighash_type)
  end

  def self.parse(signature)
    fields = *[signature].pack('H*').unpack('CCCCH66CCH64C')
    Der.new r: fields[4], s: fields[7], sighash_type: fields[8]
  end
end
