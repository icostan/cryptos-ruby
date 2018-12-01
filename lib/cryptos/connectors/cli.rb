module Cryptos
  module Connectors
    class Cli
      attr_reader :program, :network, :verbose

      def initialize(program: 'bitcoin-cli', network: 'regtest', verbose: false)
        @program = program
        @network = network
        @verbose = verbose
      end

      def import_address(address, run_mode: :system)
        run "importaddress #{address} '' false", run_mode: run_mode
      end

      def generate_to_address(address, blocks: 101, run_mode: :system, verbose: false)
        run "generatetoaddress #{blocks} #{address}"
      end

      def generate(blocks: 1, run_mode: :system)
       run "generate #{blocks}"
      end

      def list_unspent(address, run_mode: :inline)
        run "listunspent 1 9999 \"[\\\"#{address}\\\"]\"", run_mode: run_mode
      end

      def send_raw_transaction(rawtx, run_mode: :system)
        run "sendrawtransaction #{rawtx}", run_mode: run_mode
      end

      def test_raw_transaction(rawtx, run_mode: :inline)
        run "testmempoolaccept '[\"#{rawtx}\"]'", run_mode: run_mode
      end

      def get_block_count
        run("getblockcount", run_mode: :inline).to_i
      end

      def get_received_by_address(address)
        result = run "getreceivedbyaddress #{address}", run_mode: :inline
        result.strip
      end

      # private

      def run(args, run_mode: :system, debug: false)
        cmd = "#{program} -#{network} #{args}"
        puts "==> #{cmd} run_mode=#{run_mode} verbose=#{debug}" if debug || verbose
        case run_mode
        when :inline
          output = `#{cmd}`
          puts output if debug || verbose
          output
        when :system
          success = system cmd, out: '/dev/null'
          fail "failed command: #{args}" unless success
          success
        when :daemon
          pid = spawn cmd
          sleep (ENV['BOOTSTRAP'] || 10).to_i
          pid
        else
          raise "dont know how to run #{run_mode}"
        end
      end
    end
  end
end
