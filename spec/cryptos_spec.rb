RSpec.describe Cryptos do
  it 'has a version number' do
    expect(Cryptos::VERSION).not_to be nil
  end
end
