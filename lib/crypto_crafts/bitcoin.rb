require 'json'
require 'digest'
require 'securerandom'

module Bitcoin
  class Address
    include Base58
    extend Base58

    attr_reader :value, :public_key

    #
    # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
    #
    def self.from_pk(public_key, network = 0x6f)
      prefix = network.to_s(16).rjust 2, '0'
      ripemd160 = hash160 public_key
      with_version = "#{prefix}#{ripemd160}"
      checksum = hash256(with_version)[0, 8]
      wrap_encode = "#{with_version}#{checksum}"
      value = base58_encode(wrap_encode)
      new value, public_key
    end
    def initialize(value, public_key = nil)
      @value = value
      @public_key = public_key
    end
    def to_hash160
      public_key ? hash160(public_key) : base58_decode(value)[2, 40]
    end
    def to_s
      value
    end
  end
end

def hash160(data)
  sha256 = Digest::SHA256.digest([data].pack('H*'))
  Digest::RMD160.hexdigest sha256
end

def hash256(data)
  sha256 = Digest::SHA256.digest([data].pack('H*'))
  Digest::SHA256.hexdigest sha256
end

def bitcoin_new_private_key
  1 + SecureRandom.random_number(EC_n - 1)
end
def bitcoin_new_public_key(private_key)
  px, py = ec_multiply(private_key, EC_Gx, EC_Gy, EC_p)
  (px**3 + 7 - py**2) % EC_p == 0 || raise('public key point is not on the curve')
  "#{py > 0 ? '02' : '03'}#{px.to_s(16)}"
end

#
# Bitcoin
#
def bitcoin_script(address)
  hash160 = address.to_hash160
  if address.to_s.start_with? '2'
    "OP_HASH160 #{hash160} OP_EQUAL"
  else
    "OP_DUP OP_HASH160 #{hash160} OP_EQUALVERIFY OP_CHECKSIG"
  end
end

Input = Struct.new :value, :tx_hash, :index, :unlock_script, :sequence do
  def self.from_utxo(data, options = {debug: false})
    utxo = JSON.parse(data).first
    puts utxo if options[:debug]
    txid = utxo['txid']
    vout = utxo['vout']
    amount = utxo['amount']
    Input.new amount * 10**8, txid, vout
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
