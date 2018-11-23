require 'spec_helper'

RSpec.describe Deribit::Client do
  it '#get_instruments' do
    instruments = subject.get_instruments
    expect(instruments).to be_kind_of Hashie::Array
    instrument = instruments.first
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.instrumentName).to include 'BTC-'
  end
  it '#get_trades' do
    trades = subject.get_trades
    expect(trades).to be_kind_of Hashie::Array
    trade = trades.first
    expect(trade).to be_a Hashie::Mash
    expect(trade.instrument).to include 'BTC-'
    expect(trade.quantity).to be > 0
  end
  it '#get_summary' do
    summaries = subject.get_summary
    expect(summaries).to be_kind_of Hashie::Array
    summary = summaries.first
    expect(summary).to be_a Hashie::Mash
    expect(summary.instrumentName).to include 'BTC-'
    expect(summary.openInterest).to be >= 0
  end
  it '#stats' do
    stats = subject.stats
    expect(stats).to be_kind_of Hashie::Mash
    instrument = stats.btc_usd
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.futuresVolume).to be > 0
    expect(instrument.putsVolume).to be > 0
    expect(instrument.callsVolume).to be > 0
  end
end
