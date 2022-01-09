require 'csv'


CSV.foreach("./data/nba_player_data_light.csv", :headers => true) do |row|
    puts row.inspect
end