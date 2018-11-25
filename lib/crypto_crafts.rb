require 'httparty'
require 'hashie'

require 'crypto_crafts/version'

require 'crypto_crafts/base'
require 'crypto_crafts/base58'
require 'crypto_crafts/hashing'
require 'crypto_crafts/elliptic_curve'
require 'crypto_crafts/connectors/cli'

require 'crypto_crafts/private_key'
require 'crypto_crafts/public_key'
require 'crypto_crafts/address'
require 'crypto_crafts/script'
require 'crypto_crafts/input'
require 'crypto_crafts/output'
require 'crypto_crafts/transaction'
require 'crypto_crafts/der'

# currencies
require 'crypto_crafts/bitcoin'
require 'crypto_crafts/litecoin'

# exchanges
require 'crypto_crafts/deribit/client'
require 'crypto_crafts/bitmex/client'

module CryptoCrafts
  # autoload :Litecoin, 'crypto_crafts/litecoin.rb'
end
