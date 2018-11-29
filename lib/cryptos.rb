require 'httparty'
require 'hashie'

require 'cryptos/version'

require 'cryptos/utils/bytes'
require 'cryptos/utils/hexas'
require 'cryptos/utils/hashes'

require 'cryptos/base58'
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

module Cryptos
  # currencies
  autoload :Bitcoin, 'cryptos/bitcoin'
  autoload :Litecoin, 'cryptos/litecoin'

  # exchanges
  autoload :Bitmex, 'cryptos/bitmex/client'
  autoload :Deribit, 'cryptos/deribit/client'
end
