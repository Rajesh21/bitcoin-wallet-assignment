# wallet created by raj21
# GitHub Link: https://github.com/Rajesh21/bitcoin-wallet-assignment
require 'bitcoin'
require 'json'
require 'csv'
Bitcoin.network = :regtest
include Bitcoin::Builder
# To connect regtest RPC
require_relative 'bitcoinrpc.rb'
# To validate user input
require_relative 'validation.rb'
# To perform various operation
require_relative 'operation.rb'
# Common function which can be used in any code
require_relative 'helper_functions.rb'

# Global variable used overall file
BITCOIN_RPC =
BitcoinRPC.new('http://rajesh:jab_raj_meets_satoshi@127.0.0.1:18332')
# satoshi
BTC = 1_000_000_00
# mention in assignment
FEE = 1000
FILE_NAME = 'keys.csv'

# entry point
if !ARGV.empty?
  command = ARGV[0]
  case command
  when 'help'
    help
  when 'listutxo'
    if ARGV.length > 1
      puts 'No argument with \'listutxo\' command please try running\n\'ruby wallet.rb listutxo\''
    else
      listallutxo = all_utxo
      if listallutxo.size > 0
        puts JSON.pretty_generate(listallutxo)
        puts "Total UTXO's: #{listallutxo.length}"
        balance = 0
        listallutxo.each { |utxo|
        balance += utxo['value']
        }
        puts "Total balance in wallet: #{balance}"
      else
        puts "You don't have any UTXO to be spent, please gain some sathoshi's."
      end
    end
  when 'generatekey'
    if ARGV.length > 1
      puts 'No argument with \'generatekey\' command please try running\n\'ruby wallet.rb listutxo\''
    else
      generate_key
    end
  when 'listkey'
    if ARGV.length > 1
      puts 'No argument with \'listkey\' command please try running\n\'ruby wallet.rb listutxo\''
    else
      list_key
    end
  when 'sendtoaddress'
    if ARGV.length < 4
      puts 'Invalid argument-list with \'sendtoaddress\' command please try running\n\'ruby wallet.rb sendtoaddress _UnspentTXID_ _vout_ _Amount_ _ToAddress_ \''
    else
      check_valid_parameter_list = valid_send_to_parameter_list(false, *ARGV)
      if check_valid_parameter_list['status']
        # puts 'validation are ok now going to send_to_address'
        new_transaction_id = send_to_address(ARGV[1], ARGV[2].to_i, ARGV[4], ARGV[3].to_f)
        puts "Transaction sent successfully.\nTransaction Id: #{new_transaction_id}"
      else
        puts JSON.pretty_generate(check_valid_parameter_list)
      end
    end
  when 'sendtomultisig'
    if ARGV.length < 4
      puts "Invalid argument-list with \'sendtomultisig\' command please try running\n\'ruby wallet.rb sendtomultisig _UnspentTXID_ _vout_ _Amount_ _Address1_..._AddressN \'"
    else
      validate_input = valid_multi_sig_parameter_list(*ARGV)
      if validate_input['status']
        list_of_addresses = []
        for i in 4..(ARGV.length - 1) do
          list_of_addresses << ARGV[i]
        end
        new_transaction_id = send_to_multisig(ARGV[1], ARGV[2].to_i, ARGV[3].to_f, *list_of_addresses)
        if !new_transaction_id.nil?
          puts "Transaction sent successfully! \nTransaction Id:#{new_transaction_id}"
        else
          puts 'Transaction failed to send'
        end
      else
        p validate_input
      end
    end
  when 'redemtoaddress'
    if ARGV.length < 4
      puts 'Invalid argument-list with \'redeemtoaddress\' command please try running\n\'ruby wallet.rb redeemtoaddress _UnspentMultisigTXID_ _vout_ _Amount_ _Address_ \''
    else
      check_valid_parameter_list = valid_send_to_parameter_list(true, *ARGV)
      if check_valid_parameter_list['status']
        new_transaction_id = redem_to_address(ARGV[1], ARGV[2].to_i, ARGV[3].to_f, ARGV[4])
        if !new_transaction_id.nil?
          puts "Transaction sent successfully! \nTransaction Id: #{ new_transaction_id }"
        else
          puts 'Transaction failed to send over network'
        end
      else
        puts JSON.pretty_generate(check_valid_parameter_list)
      end
    end
  else
    puts 'Sorry !!! You mis-spelled command, if you need any help try running\n\'ruby wallet.rb help\''
  end
else
  puts 'Sorry !!! You forgot to send command, if you need any help try running\n\'ruby wallet.rb help\''
end
