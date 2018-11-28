RSpec.describe Cryptos::Der do
  it '#initialize' do
    der = Cryptos::Der.new r: 'r'
    expect(der.r).to eq 'r'
    expect(der.s).to be_nil
    expect(der.sighash_type).to eq 0x01
  end

  it '#serialize' do
    signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
    der = Cryptos::Der.new r: 0x884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb,
                           s: 0x4b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e3813
    expect(der.serialize).to eq signature
  end
end
