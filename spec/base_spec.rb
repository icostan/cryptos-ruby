RSpec.describe 'Base' do
  describe Der do
    it '#initialize' do
      der = Der.new r: 'r'
      expect(der.r).to eq 'r'
      expect(der.s).to be_nil
      expect(der.sighash_type).to eq 0x01
    end

    it '#serialize' do
      signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
      der = Der.new r: 0x884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb,
                    s: 0x4b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e3813
      expect(der.serialize).to eq signature
    end
  end

  describe 'utils' do
    before do
      @x = 0x09A4D6792295A7F730FC3F2B49CBC0F62E862272F
      @x_hex = @x.to_s 16
      @x_bytes = [@x_hex].pack 'H*'
    end
    it '#bytes_to_bignum' do
      expect(bytes_to_bignum(@x_bytes)).to eq @x
    end
    describe '#bignum_to_bytes' do
      it 'w/o length' do
        expect(bignum_to_bytes(@x)).to eq @x_bytes
      end
      it 'w/ length' do
        bytes_string = bignum_to_bytes(@x, 32)
        expect(bytes_string.bytes.size).to eq 32
        expect(bytes_string).to end_with @x_bytes
      end
    end
  end
end
