puts 'loading deribit...'

module Deribit
  class Client
    include HTTParty
    base_uri 'https://test.deribit.com/api/v1/public'

    def initialize
      @options = {}
    end

    def get_instruments
      execute '/getinstruments'
    end

    def get_trades(type = :all)
      execute '/getlasttrades', query: { instrument: type }
    end

    def get_summary(type = :all)
      execute '/getsummary', query: { instrument: type }
    end

    def stats
      execute '/stats'
    end

    private

    def execute(uri, options = {})
      response = self.class.get uri, options
      fail response.message unless response.success?
      fail response.body unless response['success']

      Hashie::Mash.new(response.to_hash).result
    end
  end
end
