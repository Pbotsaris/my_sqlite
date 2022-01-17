require 'csv'
class Table
  attr_accessor :column, :filename

  def initialize(path)
    @filename = path
    @column = CSV.foreach(@filename, headers: true)
  end

  def read_csv
    CSV.foreach(@filename, headers: true) do |row|
      puts row.inspect
    end
    puts '-------------------------'
  end

  def write_csv

    CSV.open(@filename, 'a+') do |csv|
      csv << ["Heather Kesto", "5", "55", "F"]
    end
  end

  def attrs
    [@column]
  end
end

table = Table.new('src/data/nba_player_data_light.csv')
table.read_csv
table.write_csv
