module Cryptos
  class Script
    include Utils::Hexas, Utils::Hashes

    OPCODES = {
      'OP_0' =>  0x00,
      'OP_1' =>  0x51,
      'OP_2' =>  0x52,
      'OP_DUP' =>  0x76,
      'OP_HASH160' =>  0xA9,
      'OP_EQUAL' =>  0x87,
      'OP_EQUALVERIFY' =>  0x88,
      'OP_CHECKSIG' =>  0xAC,
      'OP_CHECKMULTISIG' => 0xAE
    }.freeze

    attr_reader :script

    # scriptSig for pay-to-pubkey-hash outputs
    # @param der - signature in der format
    # @param public_key - the public key
    # @return script - a Script object holding scriptSig
    def self.sig_pubkey(der, public_key)
      new "#{der.serialize} #{public_key.to_sec}"
    end

    # scriptSig for pay-to-multisig-hash outputs
    def self.sig_multisig(der1, der2, redeem_script)
      new "OP_0 #{der1.serialize} #{der2.serialize} #{redeem_script.serialize}"
    end

    def self.p2pkh(address_or_hex)
      hash160 = if address_or_hex.is_a? String
                  Address.to_hash160 address_or_hex
                else
                  address_or_hex.to_hash160
                end
      new "OP_DUP OP_HASH160 #{hash160} OP_EQUALVERIFY OP_CHECKSIG"
    end

    def self.p2sh(script)
      new "OP_HASH160 #{script.to_hash160} OP_EQUAL"
    end

    # multisign redeem script
    def self.multisig(address1, address2)
      new "OP_2 #{address1.public_key.to_sec} #{address2.public_key.to_sec} OP_2 OP_CHECKMULTISIG"
    end

    def self.bare(script)
      new script
    end

    def initialize(script)
      @script = script
    end

    def to_hash160
      hash160 to_hex
    end

    def to_hex
      @hex ||= to_asm.split.map { |token| token.start_with?('OP') ? opcode(token) : data(token) }.join
    end
    alias :serialize :to_hex

    def to_asm
      script.to_s
    end

    def to_s
      to_asm
    end

    def size
      [to_hex].pack('H*').size
    end

    private

    def opcode(token)
      raise "opcode #{token} not found" unless OPCODES.include?(token)
      byte_to_hex OPCODES[token]
    end

    def data(token)
      bin_size = data_size token
      # TODO: data size is defined as 1-9 bytes
      byte_to_hex(bin_size) + token
    end

    def data_size(token)
      [token].pack('H*').size
    end
  end
end
