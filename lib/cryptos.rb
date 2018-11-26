require 'httparty'
require 'hashie'

require 'cryptos/version'

require 'cryptos/base'
require 'cryptos/base58'
require 'cryptos/hashing'
require 'cryptos/elliptic_curve'
require 'cryptos/connectors/cli'

require 'cryptos/private_key'
require 'cryptos/public_key'
require 'cryptos/address'
require 'cryptos/script'
require 'cryptos/input'
require 'cryptos/output'
require 'cryptos/transaction'
require 'cryptos/der'

# currencies
require 'cryptos/bitcoin'
require 'cryptos/litecoin'

# exchanges
require 'cryptos/deribit/client'
require 'cryptos/bitmex/client'

module CryptoCrafts
  # autoload :Litecoin, 'cryptos/litecoin.rb'
end
