require 'spec_helper'

RSpec.describe Base58 do
  include Base58

  it 'base58_encode' do
    result = base58_encode '00f54a5851e9372b87810a8e60cdd2e7cfd80b6e31c7f18fe8'
    expect(result).to eq '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
  end
  it 'base58_decode' do
    result = base58_decode '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'
    expect(result).to eq '00f54a5851e9372b87810a8e60cdd2e7cfd80b6e31c7f18fe8'
  end
end
