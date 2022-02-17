# frozen_string_literal: true
require_relative './utils'
require 'pp'

# a request
class Request
  include Utils
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
    if @request[:action] == :join
      @request[:join][:where] = where
    else
      @request[:where] = where
    end
  end

  def order(columns, option)
    @request[:order] = { columns: columns, sort: option ? option.downcase.to_sym : :asc }
  end

  def join(table)
    @request[:join][:table] = table
    @request[:action] = :join
  end

  def on(on)
    column, join_column = on

    return if column.nil? || join_column.nil?

    column = column.include?('.') ? _remove_dot(column) : column
    join_column = join_column.include?('.') ? _remove_dot(join_column) : join_column

    @request[:join][:on] = [column, join_column]
  end

  def run
    select_csv = _handle_csv?(@request[:table], 'select_temp')
    join_csv   = _handle_csv?(@request[:join][:table], 'join_temp')
    return unless _table_exists?(@request[:table])

    case @request[:action]
    when :select
      _select
    when :insert
      _insert
    when :delete
      _delete
    when :update
      _update
    when :join
      _join
    end
    @database.free_table('select_temp') if select_csv
    @database.free_table('join_temp') if join_csv
  end

  private

  # if user passes a CSV path as a table the program will load and index data in place.
  # Though this is a less efficient way to run the program

  def _handle_csv?(table, name)
    return false if table.nil?
    return false unless table.match?(/^.*\.csv/)
    return false unless @database.create_temp_table(table, name)

    if name == 'select_temp'
      @request[:table] = name
    else
      @request[:join][:table] = name
    end
    true
  end

  def _select
    if _where?
       table = _select_without_where
      Printer.print_table_hashes(table, @request[:columns]) unless table.nil?
    else
      table = _select_where
      Printer.print_table_arrays(table[:data], table[:columns]) unless table.nil? || table[:data].nil?
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

  def _join
    return unless _table_exists?(@request[:join][:table])

    return unless columns_exist? @request[:table], @request[:join][:on][0]
    return unless columns_exist? @request[:join][:table], @request[:join][:on][1]

    if _where?
      _join_without_where
    else
      _join_where
    end
  end

  def _join_without_where
    select = _select_without_where
    join = _select_join
    return if join.nil? || select.nil?

    joined = _merge_tables(select, join)
    joined = _filter_join(joined)
    Printer.print_table_hashes(joined, @request[:columns]) unless joined.nil?
  end

  def _join_where
    select = _select_where
    select[:headers] = _get_headers(@request[:table])

    return if select.nil? || select[:data].nil?

    select[:data] = _array_table_to_hash_table(select)
    join = _select_join

    joined = _merge_tables(select[:data], join)
    joined = _filter_join(joined)
    Printer.print_table_hashes(joined, @request[:columns]) unless joined.nil?
  end

  def _select_without_where
    @database.instance_variable_get("@#{@request[:table]}").list(@request[:columns], @request[:order])
  end

  def _select_where
    # program supports only a single where clase at this point
    where = @request[:where][0]
    @database.instance_variable_get("@#{@request[:table]}").list_where(@request[:columns], where, @request[:order])
  end

  def _select_join
    @database.instance_variable_get("@#{@request[:join][:table]}").list('*', @request[:order])
  end

  def _filter_join(table)
    return table.dup if @request[:join][:where].empty?

    where = @request[:join][:where][0]
    column = where[:column]
    table.select { |row| row[column] == where[:term] }
  end

  def _init_request
    { table: nil,
      columns: [],
      values: [],
      where: [],
      order: { columns: nil, sort: :asc },
      join: { table: nil, on: [], where: [] },
      action: nil }
  end

  def _table_exists?(table)
    tables = @database.list_tables

    unless tables.include?(table)
      puts "Table #{table} does not exist." if table
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

  def _where?
    @request[:where].empty?
  end

  def columns_exist?(table, column)
    table_headers = _get_headers(table)
    unless table_headers.include?(column)
      puts "The column #{column} does not exist in the table #{table}"
      return false
    end
    true
  end

  def _get_headers(table)
    @database.instance_variable_get("@#{table}").headers
  end

  def _convert_values(values)
    values.map do |value|
      value.is_a?(Integer) ? value.to_s : value
    end
  end

  def _merge_tables(select, join)
    joined = []

    column = @request[:join][:on][0]
    column_join = @request[:join][:on][1]

    select.each do |row|
      new_row = {}
      join.each do |join_row|
        new_row = join_row[column_join] == row[column] ? row.merge!(join_row) : row
      end
      joined.append(new_row)
    end
    joined
  end

  def _array_table_to_hash_table(select)
    select[:data] = select[:data].map do |row|
      result_row = {}
      select[:columns].each do |column_index|
        key = select[:headers][column_index - 1]
        result_row[key] = row[column_index] unless key.nil?
      end
      result_row
    end
  end

  def _remove_dot(string)
    _table, column = string.split('.')
    column
  end
end
