# frozen_string_literal: true

# a request
class Request
  attr_reader :request, :valid, :complete
  alias valid? valid
  alias complete? complete

  def initialize(path)
    @database = Database.new(path)
    @request = _init_request
    @valid = true
    @complete = false
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
    return unless _table_exists?

    case @request[:action]
    when :select
      _select
    end
  end

  private

  def _select
    if @request[:where].empty?
      @database.instance_variable_get("@#{@request[:table]}").list(@request[:columns])
    else
      # program supports only a single where clase at this point
      where = @request[:where][0]
      @database.instance_variable_get("@#{@request[:table]}").list_where(@request[:columns], where)
    end
  end

  def _init_request
    { table: nil, columns: [], values: [], where: [], order: {}, join: {}, action: nil }
  end

  def _table_exists?
    tables = @database.list_tables

    unless tables.include?(@request[:table])
      puts "Table #{@request.request[:table]} does not exist" if @request.request[:table]
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
