require 'yaml'


config = YAML.load_file(ARGV.first || './config.yml')
puts 'Please Enter Your Account Number:'
card_number = gets.chomp
puts 'Enter Your Password:'
password = gets.chomp

if config['accounts'][card_number.to_i].nil?
  puts 'ERROR: WRONG ACCOUNT NUMBER'
  return
elsif password == config['accounts'][card_number.to_i]['password']
  puts "Hello, #{config['accounts'][card_number.to_i]['name']}\n"
else
  puts 'ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH'
  return
end

def atm_cash(config)
  atm_cash = config['banknotes'].reduce(0) do |sum, (key, value)|
    sum + key * value
  end
end

def if_composed?(get_cash, config)
  treasure = Array(config['banknotes'].keys)
  values = Array(config['banknotes'].values)

  (config['banknotes'].keys.count).times do |k|
    money_in_atm = (get_cash - (get_cash % treasure[k])) / treasure[k]
    if money_in_atm <= values[k]
      get_cash -= treasure[k] * money_in_atm
      config['banknotes'][treasure[k]] -= money_in_atm
    else
      get_cash -= treasure[k] * values[k]
    end
  end
  File.open("./config.yml", 'w') { |f| YAML.dump(config, f) }
  get_cash == 0
end

loop do
  puts "\nPlease Choose From the Following Options:
      1. Display Balance
      2. Withdraw
      3. Log Out\n"
  select_menu = gets.chomp.to_i
  case select_menu
    when 1
      puts "\nYour Current Balance is ₴#{config['accounts'][card_number.to_i]['balance']}"
    when 2

      loop do
        puts "\nEnter Amount You Wish to Withdraw:\n"
        get_cash = gets.chomp.to_i

        if get_cash < 0
          puts "\nAMOUNT CAN\'T BE NEGATIVE\n"
          get_cash = 0
        elsif get_cash > atm_cash(config)
          puts "\nTHE MAXIMUM AMOUNT AVALIBLE IN THIS ATM IS ₴#{atm_cash(config)}. PLEASE ENTER A DIFFERENT AMOUNT\n"
        elsif get_cash > config['accounts'][card_number.to_i]['balance'].to_i
          puts "\nERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT\n"
        elsif !if_composed?(get_cash, config)
          puts "\nTHE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT\n"
        else
          new_balance = config['accounts'][card_number.to_i]['balance'].to_i - get_cash
          config['accounts'][card_number.to_i]['balance'] = new_balance
          File.open("./config.yml", 'w') { |f| YAML.dump(config, f) }
          puts "\nYour New Balance is ₴#{new_balance}\n"
          break
        end
      end
    when 3
      puts "\n#{config['accounts'][card_number.to_i]['name']}, Thank You For Using Our ATM. Good-Bye!"
      return
    else
      puts "\nERROR: WRONG INPUT\n"
  end
end
