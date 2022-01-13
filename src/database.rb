# frozen_string_literal: true

require 'csv'
require_relative './trie'

#  Indexes class uses a Trie data structure to keep the indexes of each columns
#  Indexes are stored in memory for quick access when a database and tables classes are instantiated.
class Indexes
  def load(path, headers)
    file = File.read path
    data = CSV.parse file, headers: true
    _set_columns(headers)
    _read_column(data, headers)
  end

  def find(column, name)
    found = instance_variable_get("@#{column}").find name
    found&.id
  end

  private

  def _read_column(data, headers)
    data.each do |row|
      headers.each do |header|
        instance_variable_get("@#{header}").insert(row[0], row[header]) unless header.nil?
      end
    end
  end

  def _set_columns(headers)
    headers.each do |header|
      instance_variable_set("@#{header}", Trie.new) unless header.nil?
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
    @indexes.load @path, @headers
  end

  def where(column, term)
    return nil unless @headers.include? column

    indexes = @indexes.find(column, term)

    return nil if indexes.nil?

    indexes = indexes.map(&:to_i)

    _read indexes.sort
  end

  private

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
  def initialize(path)
    table_files = _parse_keypairs(path)
    _load_tables(table_files)
  end

  def list_table
    instance_variables
  end

  private

  def _load_tables(table_files)
    table_files.each do |table_file|
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
end
