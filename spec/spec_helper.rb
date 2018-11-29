require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'bundler/setup'
require 'cryptos'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def ci?
  ENV['CI'] == 'true'
end

# def am_i_rich?(address)
#   return if ci?

#   output = run_command "bx fetch-balance -f json #{address.rich}"
#   data = JSON.parse(output)
#   if data['balance']['received'].to_i > 0
#     puts output
#     raise " ************* I AM RICH #{address.public_key.private_key.to_s}"
#   end
# end

# def run_command(cmd, v: false, run_mode: :inline)
#   puts "==> #{cmd}"
#   case run_mode
#   when :inline
#     output = `#{cmd}`
#     puts output if v
#     output
#   when :system
#     success = system cmd
#     expect(success).to be_truthy
#     success
#   when :daemon
#     pid = spawn cmd
#     sleep (ENV['BOOTSTRAP'] || 10).to_i
#     pid
#   else
#     raise "dont know how to run #{run_mode}"
#   end
# end

def generate_and_check(cli, address, amount)
  cli.run 'generate 1'
  result = cli.run "getreceivedbyaddress #{address}"
  expect(result).to include amount
end
