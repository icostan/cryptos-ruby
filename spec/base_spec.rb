RSpec.describe 'Base' do
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
