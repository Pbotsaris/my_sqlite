# frozen_string_literal: true

# a request
class Request
  attr_reader :request, :valid, :complete
  alias valid? valid
  alias complete? complete

  def initialize(database)
    @database = database
    @request = _init_request
    @valid = true
    @complete = false
  end

  def load_database(database)
    @database = database
  end

  def reset
    @request = _init_request
  end

  def from(table)
    @request[:table] = table
  end

  # columns is an array
  def select(columns)
    @request[:columns] = columns
    @request[:action] = :select
  end

  def insert(table)
    @request[:table] = table
    @request[:action] = :insert
  end

  def update(table)
    @request[:table] = table
    @request[:action] = :update
  end

  def delete
    @request[:action] = :delete
    @request[:columns] = ['*']
  end

  # values = array
  def values(values)
    values = _convert_values(values)
    @request[:values] = values
    @request[:columns] = ['*']
  end

  # columns and values are arrays
  def set(columns, values)
    values = _convert_values(values)

    @request[:columns] = columns
    @request[:values] = values
  end

  def where(columns, values)
    where = columns.each_with_index.map do |column, i|
      # integer needs to be converted to strings for TRIE
      { column: column, term: values[i].is_a?(Integer) ? values[i].to_s : values[i] }
    end

    @request[:where] = where
  end

  def order(columns, option)
    @request[:order] = { columns: columns, sort: option ? option.downcase.to_sym : :asc }
  end

  def join(table)
    @request[:join] = { table: table, columns: ['*'] }
  end

  def on(columns)
    @request[:join][:columns] = columns
  end

  def run
    csv = _handle_csv?
    return unless _table_exists?

    case @request[:action]
    when :select
      _select
    when :insert
      _insert
    when :delete
      _delete
    when :update
      _update
    end

    @database.free_table('temp') if csv
  end

  private

  # if user passes a CSV path as a table the program will load and index data in place.
  # Though this is a less efficient way to run the program

  def _handle_csv?
    return false if @request[:table].nil?
    return false unless @request[:table].match?(/^.*\.csv/)

    @database.create_temp_table(@request[:table])

    @request[:table] = 'temp'
    true
  end

  def _select
    if @request[:where].empty?
      @database.instance_variable_get("@#{@request[:table]}").list(@request[:columns], @request[:order])
    else
      # program supports only a single where clase at this point
      where = @request[:where][0]
      @database.instance_variable_get("@#{@request[:table]}").list_where(@request[:columns], where, @request[:order])
    end
  end

  def _insert
    return if @request[:values].nil?

    table_length = @database.instance_variable_get("@#{@request[:table]}").headers.length

    if @request[:values].length < table_length
      puts 'Number of columns in VALUES does not match'
      return
    end
    @database.instance_variable_get("@#{@request[:table]}").append(@request[:values])
  end

  def _update
    return unless _valid_to_update?

    to_update = @request[:columns].each_with_index.map do |column, i|
      { column: column, value: @request[:values][i] }
    end

    where = @request[:where][0]

    @database.instance_variable_get("@#{@request[:table]}").update(to_update, where)
  end

  def _delete
    # delete must have a where clause to prevent deleting a whole table
    if @request[:where].empty?
      puts 'DELETE must be accompanied by a WHERE clause'
      return
    end

    where = @request[:where][0]
    @database.instance_variable_get("@#{@request[:table]}").delete(where[:column], where[:term])
  end

  def _init_request
    { table: nil, columns: [], values: [], where: [], order: { columns: nil, sort: :asc }, join: {}, action: nil }
  end

  def _table_exists?
    tables = @database.list_tables

    unless tables.include?(@request[:table])
      puts "Table #{@request[:table]} does not exist" if @request[:table]
      return false
    end
    true
  end

  def _valid_to_update?
    if @request[:values].empty? || @request[:columns].empty?
      puts 'Specify the columns and values to update with a SET clause'
      return false
    end

    if @request[:where].empty?
      puts 'Select the row to update with a WHERE cluase'
      return false
    end
    true
  end

  def _convert_values(values)
    values.map do |value|
      value.is_a?(Integer) ? value.to_s : value
    end
  end
end
