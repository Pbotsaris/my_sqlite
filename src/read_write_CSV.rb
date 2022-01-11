require 'csv'

class Table
    column = CSV.parse(("./data/nba_player_data_light.csv"), headers: true)
    attr_accessor :column

    column.each do |column_row|
        p column_row
    end

    def initialize(column)
        @column =  column
    end

    def read_csv
        CSV.foreach("./data/nba_player_data_light.csv", :headers => true) do |row|
            puts row.inspect
        end
    end

    def attrs 
        [column]
    end

end