# frozen_string_literal: true

require_relative './request'
require_relative './database/database'

# interface with database using ruby
class MySqliteRequest
  def initialize
    # use the temp db for this interface
    @database = Database.new('data/temp.db')
    @request = Request.new(@database)
    @request.cli = false
  end

  def run
    @request.run
  end

  def from(table)
    @request.from table
    self
  end

  def select(columns)
    columns.is_a?(Array) ? @request.select(columns) : @request.select([columns])
    self
  end

  def where(column, criteria)
    @request.where([column], [criteria])
    self
  end

  def join(column, table, column_to_join)
    @request.join(table)
    @request.on([column, column_to_join])
    self
  end

  def order(order, column)
    case order
    when :asc
      @request.order(column, 'ASC')
    when :desc
      @request.order(column, 'DESC')
    else
      puts "#{order} is an invalid order option"
    end
    self
  end

  def update(table)
    @request.update(table)
    self
  end

  def insert(table)
    @request.insert(table)
    self
  end

  def set(data)
    columns = []
    values = []
    data.each do |key, value|
      columns.append(key)
      values.append(value)
    end

    @request.set(columns, values)
    self
  end

  def values(values)
    v = []
    values.each do |_key, value|
      v.append(value)
    end
    @request.values(v)
    self
  end

  def delete
    @request.delete
    self
  end
end

request = MySqliteRequest.new

# QUERY
# request = request.from('nba_player_data.csv')
# request = request.select('name')
# request = request.where('college', 'University of California')

# INSERT
#
# request = request.insert('nba_player_data.csv')
# request = request.values('name' => 'Alaa Abdelnaby', 'year_start' => '1991', 'year_end' => '1995', 'position' => 'F-C', 'height' => '6-10', 'weight' => '240', 'birth_date' => "June 24, 1968", 'college' => 'Duke University')

# UPDATE
#
# request = request.update('nba_player_data.csv')
# request = request.set('name' => 'Alaa Renamed')
# request = request.where('name', 'Alaa Abdelnaby')

# DELETE
#
# request = request.delete
# request = request.from('nba_player_data.csv')
# request = request.where('name', 'Alaa Abdelnaby')

# request.run
