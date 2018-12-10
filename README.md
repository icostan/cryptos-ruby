# Cryptos-ruby

[![Build Status](https://travis-ci.org/icostan/cryptos-ruby.svg?branch=master)](https://travis-ci.org/icostan/cryptos-ruby)
[![Maintainability](https://api.codeclimate.com/v1/badges/3e4566b45ebc3f887cef/maintainability)](https://codeclimate.com/github/icostan/cryptos-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3e4566b45ebc3f887cef/test_coverage)](https://codeclimate.com/github/icostan/cryptos-ruby/test_coverage)
[![Gem Version](https://badge.fury.io/rb/cryptos.svg)](https://badge.fury.io/rb/cryptos)

### The Why - the vision and goals

  * I believe there are none of very few Ruby implementations and support for different crypto technologies
  * I like to craft my own wallets, transactions, block explorers in all shapes and forms
  * I dream to execute atomic swaps between any crypto coins out there

### The How - the actions

  * Implementing basic cryptography from scratch - elliptic curves math, digital signature schemes, etc
  * Building a simple and easy to use Ruby API
  * Lean and continuous improvment along the way (aka adding more coins) while I understand more advanced concepts: pairing cryptography

### The What - the features

  * Generate private and public keys
  * Generate addresses for Bitcoin, Litecoin, Ethereum and much more
  * Create transaction to spend standard inputs or more complex multisig, hashed timelock contracts
  * Execute atomic swaps between Bitcoin and Litecoin, more to come
  * TODO: Create, import, export wallets

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cryptos'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cryptos

## Usage

### Scenario 1: Spend coinbase transaction

Alright, let's begin, first thing first, lets generate private and public keys:

```ruby
2.5.3 :001 > private_key = Cryptos::PrivateKey.generate
 => #<Cryptos::PrivateKey:0x00007f8cc10c0ad0 @value=1991485315816438798044329630916774278846523543844864946402119577704095054145, @order=115792089237316195423570985008687907852837564279074904382605163141518161494337>
2.5.3 :002 > public_key = Cryptos::PublicKey.new private_key
 => #<Cryptos::PublicKey:0x00007f8cc105ed58 @private_key=#<Cryptos::PrivateKey:0x00007f8cc10c0ad0 @value=1991485315816438798044329630916774278846523543844864946402119577704095054145, @order=115792089237316195423570985008687907852837564279074904382605163141518161494337>, @x=107779388491921327681974754398507503201871466663959093103394577491037829153768, @y=78060352001932916201234328232450653863791592111885208305671830584742527863131>
```

Based on public key above lets create a Bitcoin address:

```ruby
2.5.3 :003 > from_address = Cryptos::Bitcoin::Address.new public_key
 => #<Cryptos::Bitcoin::Address:0x00007f8cc12fc560 @public_key=#<Cryptos::PublicKey:0x00007f8cc105ed58 @private_key=#<Cryptos::PrivateKey:0x00007f8cc10c0ad0 @value=1991485315816438798044329630916774278846523543844864946402119577704095054145, @order=115792089237316195423570985008687907852837564279074904382605163141518161494337>, @x=107779388491921327681974754398507503201871466663959093103394577491037829153768, @y=78060352001932916201234328232450653863791592111885208305671830584742527863131>, @testnet=true>
```

Before going any further we need to install bitcoin-core daemon and start node in regtest mode:

```shell
# in MacOS
brew install bitcoin

# in Linux (Debian based)
apt-get install bitcoin

# start Bitcoin daemon in regtest mode
bitcoind -regtest -printtoconsole
```

Now we create a simple Cli connector that will communicate to underlying bitcoin daemon.

```ruby
2.5.3 :004 > cli = Cryptos::Connectors::Cli.new
 => #<Cryptos::Connectors::Cli:0x00007f8cc12ece30 @program="bitcoin-cli", @network="regtest", @verbose=false>
```

Import address into node and generate 101 blocks. If you ask why 101 then it is because coinbase transactions are spendable after 100 confirmatinos.

```ruby
2.5.3 :005 > from_address.import cli
 => true
2.5.3 :006 > cli.generate_to_address from_address, blocks: 101
 => true
```

Generate and import destination address to send BTC to then check that it has no money in it.

```ruby
2.5.3 :007 > to_address = Cryptos::Bitcoin::Address.new Cryptos::PublicKey.new Cryptos::PrivateKey.generate
 => #<Cryptos::Bitcoin::Address:0x00007f8cc134f2b0 @public_key=#<Cryptos::PublicKey:0x00007f8cc128fa78 @private_key=#<Cryptos::PrivateKey:0x00007f8cc128faa0 @value=104555233989943463494354097619221894829574308702717051161491781222000198727347, @order=115792089237316195423570985008687907852837564279074904382605163141518161494337>, @x=1402024405898287938501468401055931693243587868828983898835308320263377717122, @y=89146164815925753866667564550747587615674131412309491381641677989226156891240>, @testnet=true>
2.5.3 :008 > to_address.import cli
 => true
2.5.3 :009 > to_address.get_balance cli
 => "0.00000000"
```

Alright, now we get to real stuff, transactions: create input from our ```from_address```, send 123_456_789 Satoshis (1.23456789 BTC) to our ```to_address``` and change amount back to ```from_address```.

```ruby
2.5.3 :010 > input = Cryptos::Input.from_utxo cli, from_address
 => #<struct Cryptos::Input value=2500000000.0, tx_hash="33fc8506d7a5880cfddca3c950f95fa461398fb764da4527169d5574a7c00c7b", index=0, script_sig=nil, sequence=68719476735>
2.5.3 :011 > output = Cryptos::Output.p2pkh to_address, 123_456_789
 => #<struct Cryptos::Output value=123456789, script_pubkey=#<Cryptos::Script:0x00007f8cc12ed8a8 @script="OP_DUP OP_HASH160 9aae79929e4364ab3aabe1f83a875304d1b67a3a OP_EQUALVERIFY OP_CHECKSIG">>
2.5.3 :012 > change = Cryptos::Output.p2pkh_change from_address, input, output
 => #<struct Cryptos::Output value=2376533211.0, script_pubkey=#<Cryptos::Script:0x00007f8cc12cfdd0 @script="OP_DUP OP_HASH160 57a58e05aedfbb6bd97b373baf65ce7cc318351b OP_EQUALVERIFY OP_CHECKSIG">>
2.5.3 :013 > transaction = Cryptos::Transaction.from_ioc input, output, change
 => #<struct Cryptos::Transaction version=1, inputs=[#<struct Cryptos::Input value=2500000000.0, tx_hash="33fc8506d7a5880cfddca3c950f95fa461398fb764da4527169d5574a7c00c7b", index=0, script_sig=nil, sequence=68719476735>], outputs=[#<struct Cryptos::Output value=123456789, script_pubkey=#<Cryptos::Script:0x00007f8cc12ed8a8 @script="OP_DUP OP_HASH160 9aae79929e4364ab3aabe1f83a875304d1b67a3a OP_EQUALVERIFY OP_CHECKSIG">>, #<struct Cryptos::Output value=2376533211.0, script_pubkey=#<Cryptos::Script:0x00007f8cc12cfdd0 @script="OP_DUP OP_HASH160 57a58e05aedfbb6bd97b373baf65ce7cc318351b OP_EQUALVERIFY OP_CHECKSIG">>], locktime=0>
```

Sign and broadcast the transaction:

```ruby
2.5.3 :014 > transaction.sign_single_input from_address
 => "01000000017b0cc0a774559d162745da64b78f3961a45ff950c9a3dcfd0c88a5d70685fc33000000006a473044022020b53986c2ef08d54137e57f1c231a0c2fe1b6dc88c7208ecef6f7474bae985002203027db653202da53ce081da46431ef1f88f3e1bf47254940a58740a86506cbc3012103ee48f8db1d9a5dfc1b620dbe9566b77d995e0325b91d3b661a697272920f43e8ffffffff0215cd5b07000000001976a9149aae79929e4364ab3aabe1f83a875304d1b67a3a88acdb04a78d000000001976a91457a58e05aedfbb6bd97b373baf65ce7cc318351b88ac00000000"
2.5.3 :015 > transaction.broadcast cli
 => true
```

Mine new block that will contain our hand crafted transaction and VOILA! output amount was transafered to new address.

```ruby
2.5.3 :016 > cli.generate blocks: 1
 => true
2.5.3 :017 > cli.get_received_by_address to_address
 => "1.23456789"
```

### Scenario 2: Spend multisig transaction

TBD

### Scenario 3: Atomic swaps between BTC and LTC

TBD

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icostan/cryptos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the CryptoCrafts project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/icostan/cryptos/blob/master/CODE_OF_CONDUCT.md).
