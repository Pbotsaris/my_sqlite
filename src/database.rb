# frozen_string_literal: true

require 'csv'
require_relative './trie'

#  Indexes class uses a Trie data structure to keep the indexes of each columns
#  Indexes are stored in memory for quick access when a database and tables classes are instantiated.
class Indexes
  def load(path, columns)
    file = File.read path
    data = CSV.parse file, headers: true
    _set_columns(columns)
    _read_column(data, columns)
    # resturns row count
    data.length
  end

  def find(name, column)
    found = instance_variable_get("@#{column}").find name
    found&.id
  end

  def insert_one(row, column)
    id = row[0]
    word = row[column]
    instance_variable_get("@#{column}").insert(id, word)
  end

  def delete(row, column)
    id = row[0]
    word = row[column]
    instance_variable_get("@#{column}").delete(id, word)
  end

  def delete_all(word, column)
    instance_variable_get("@#{column}").delete_all(word)
  end

  def insert(row, columns)
    0.upto(columns.length - 1) do |column_index|
      unless columns[column_index].nil?
        instance_variable_get("@#{columns[column_index]}").insert(row[0].to_s, row[column_index + 1])
      end
    end
  end

  private

  def _read_column(data, columns)
    data.each do |row|
      columns.each do |column|
        instance_variable_get("@#{column}").insert(row[0], row[column]) unless column.nil?
      end
    end
  end

  def _set_columns(columns)
    columns.each do |column|
      instance_variable_set("@#{column}", Trie.new) unless column.nil?
    end
  end
end

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

# The Database class consists of a collection of tables.
# the database tables paths are persisted to the data/db_name.db
class Database
  attr_reader :loaded
  alias loaded? loaded

  def initialize(path)
    @loaded = false
    return unless _file_exists? path, 'Database'

    @path = path
    table_files = _parse_keypairs(path)
    _load_tables(table_files)
    @loaded = true
  end

  def list_table
    # skip all other instance variables when listing tables
    instance_variables.reject { |var| var.match?(/@loaded|@path/) } if @loaded
  end

  def import_table(name, path)
    return unless _file_exists? path, 'Table'

    File.open(@path, 'a') do |file|
      file << "#{name}=#{path}"
    end
    _load_tables([{ name: name, path: path }])
  end

  private

  def _load_tables(table_files)
    table_files.each do |table_file|
      # using singletooon_class to make attrib avail with attr_accessor
      puts table_file
      singleton_class.class_eval { attr_accessor table_file[:name] }
      send("#{table_file[:name]}=", Table.new(table_file[:path]))
    end
  end

  def _parse_keypairs(path)
    table_keypairs = File.read(path).split(/\n/)
    table_keypairs.map do |table_keypair|
      table_name, table_path = table_keypair.split('=')
      { name: table_name, path: table_path }
    end
  end

  def _file_exists?(path, type)
    return true if File.file? path

    puts "error: #{type} at #{path} does not exist."
    false
  end
end
