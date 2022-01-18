# frozen_string_literal: true

require 'csv'
require 'fileutils'
require_relative './indexes'

# The table class represents a table in the database.
# You can search, read, write and update a given table using this class
# Tables are read, written and persisted from/to disk. (data directory)
class Table
  attr_reader :headers

  def initialize(path)
    @path = path
    @headers = _load_headers path
    @indexes = Indexes.new
    @next_row = @indexes.load @path, @headers
  end

  def list(columns)
    return unless _column_exists? columns

    data = CSV.parse(File.read(@path), headers: true)

    _print(data, columns)
  end

  def list_where(columns, where)
    return unless _column_exists? columns

    cols = []

    @headers.each_with_index do |header, i|
      cols.append(i) if columns.include?(header) || columns[0] == '*'
    end

    table = find(where[:column], where[:term])

    _print_table_array(table, cols)
  end

  # Finds database rows according search term in a column
  def find(column, term)
    return nil unless @headers.include? column

    indexes = @indexes.find(term, column)

    return nil if indexes.nil?

    indexes = indexes.map(&:to_i)

    _read indexes.sort
  end

  # Appends a new row to the end of the table incrementing the primary key
  def append(row)
    row.prepend @next_row
    @next_row += 1
    CSV.open(@path, 'ab') do |output|
      output << row
    end
    @indexes.insert(row, @headers)
  end

  # Deletes rows where values = term in columns
  def delete(column, term)
    indexes = @indexes.find(term, column)

    return nil if indexes.nil?

    data = CSV.parse(File.read(@path), headers: true)
    data = data.reject { |row| indexes.include?(row[0]) }
    headers = @headers.clone.prepend(nil)

    CSV.open(@path, 'w', write_headers: true, headers: headers) do |output|
      data.each { |row| output << row }
    end
    # then removes this term completely as it no longer exists in the column index
    @indexes.delete_all(term, column)
  end

  # Update accepts array with hashes as objects
  # update: [{column: 'Player' , value: 'Pedro' }, #{column: 'birth_state', value: 'indiana' }]
  # where:  {column: 'Player', term: 'Bob Evans'}
  def update(to_update, where)
    indexes = @indexes.find(where[:term], where[:column])
    return nil if indexes.nil?

    _update_rows(to_update, indexes)
  end

  private

  def _print(data, columns)
    data.each do |row|
      block = proc { |column, i| i.zero? ? print("| #{row[column]} |") : print(" #{row[column]} |") }

      columns[0] == '*' ? _print_all(row) : columns.each_with_index(&block)

      puts ''
    end
  end

  def _print_all(row)
    row.each_with_index { |column, i| i.zero? ? print("| #{column[1]} |") : print(" #{column[1]} |") }
  end

  def _print_table_array(table, cols)
    table.each do |row|
      row.each_with_index do |column, i|
        if cols.include?(i)
          i.zero? ? print("| #{column} |") : print(" #{column} |")
        end
      end
    end
    puts ''
  end

  def _column_exists?(columns)
    return true if columns[0] == '*'

    invalid = false
    columns.each { |column| invalid = column unless @headers.include?(column) }
    if invalid
      puts "#{invalid} does not exist."
      return false
    end
    true
  end

  def _update_rows(to_update, indexes)
    headers = @headers.clone.prepend(nil)

    data = CSV.parse(File.read(@path), headers: true)
    CSV.open(@path, 'w', write_headers: true, headers: headers) do |output|
      data.each do |row|
        _update_columns(row, to_update) if indexes.include?(row[0])

        output << row
      end
    end
  end

  def _update_columns(row, to_update)
    to_update.each do |column|
      column_name, value = column.values

      # also updates indexes
      @indexes.delete(row, column_name)
      row[column_name] = value
      @indexes.insert_one(row, column_name)
    end
  end

  def _read(indexes)
    file = File.open(@path)
    lines = _find_lines(file, indexes)
    file.close
    lines.map { |line| CSV.parse_line line }
  end

  def _find_lines(file, indexes)
    prev = 0
    # skipping header
    file.gets
    lines = []

    indexes.each do |index|
      (index - prev).times { file.gets }

      lines << file.gets
      prev = index + 1
    end
    lines
  end

  def _load_headers(path)
    headers = CSV.open(path, &:readline)
    headers.reject(&:nil?)
  end
end
