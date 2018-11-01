require 'digest'
require 'securerandom'

module Bitcoin
  def self.input_from_utxo(data, options = {debug: false})
    utxo = JSON.parse(data).first
    puts utxo if options[:debug]
    txid = utxo['txid']
    vout = utxo['vout']
    amount = utxo['amount']
    Input.new amount * 10**8, txid, vout
  end
end

def bitcoin_new_private_key
  1 + SecureRandom.random_number(EC_n - 1)
end
def bitcoin_new_public_key(private_key)
  px, py = ec_multiply(private_key, EC_Gx, EC_Gy, EC_p)
  ((px**3 + 7 - py**2) % EC_p == 0) || raise('public key point is not on the curve')
  "#{py > 0 ? '02' : '03'}#{px.to_s(16)}"
end
# TODO: accept network bytes insted of string
def bitcoin_new_address(public_key, prefix = '6f')
  sha256 = Digest::SHA256.hexdigest([public_key].pack('H*'))
  ripemd160 = Digest::RMD160.hexdigest([sha256].pack('H*'))
  with_version = "#{prefix}#{ripemd160}"
  checksum = Digest::SHA256.hexdigest(Digest::SHA256.digest([with_version].pack('H*')))[0, 8]
  wrap_encode = "#{with_version}#{checksum}"
  bitcoin_base58_encode(wrap_encode)
end

#
# Bitcoin
#
def bitcoin_base58_encode(ripe160_hash)
  alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  value = ripe160_hash.to_i 16
  output = ''
  while value > 0
    remainder = value % 58
    value /= 58
    output += alphabet[remainder]
  end
  output += alphabet[0] * [ripe160_hash].pack('H*').bytes.find_index{|b| b != 0}
  output.reverse
end
def bitcoin_base58_decode(address)
  alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  int_val = 0
  address.reverse.chars.each_with_index do |char, index|
    char_index = alphabet.index(char)
    int_val += char_index * 58**index
  end
  # TODO: hard coded 50?
  bignum_to_bytes(int_val, 25).unpack('H*').first
end
def bitcoin_address_decode(address)
  wrap_encode = bitcoin_base58_decode address
  wrap_encode[2, 40]
end
def bitcoin_script(address)
  hash160 = bitcoin_address_decode address
  if address.start_with? '2'
    "OP_HASH160 #{hash160} OP_EQUAL"
  else
    "OP_DUP OP_HASH160 #{hash160} OP_EQUALVERIFY OP_CHECKSIG"
  end
end

Input = Struct.new :value, :tx_hash, :index, :unlock_script, :sequence do
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
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(value) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end

Transaction = Struct.new :version, :inputs, :outputs, :locktime do
  def serialize
    inputs_hex = inputs.map(&:serialize).join
    outputs_hex = outputs.map(&:serialize).join
    int_to_hex(version) + byte_to_hex(inputs.size) + inputs_hex +
      byte_to_hex(outputs.size) + outputs_hex + int_to_hex(locktime)
  end

  def hash
    hash_to_hex sha256(sha256(serialize))
  end

  def signature_hash(lock_script = nil, sighash_type = 0x1)
    inputs.first.unlock_script = lock_script if lock_script
    hash = sha256(sha256(serialize + int_to_hex(sighash_type)))
    [hash].pack('H*')
  end

  def sign(private_key, public_key, lock_script, sighash_type = 0x01)
    bytes_string = signature_hash lock_script, sighash_type
    r, s = ecdsa_sign private_key, bytes_string
    puts "r: #{r}"
    puts "s: #{s}"
    der = Der.new r: r, s: s
    inputs.first.unlock_script = "#{der.serialize} #{public_key}"
    serialize
  end
end
