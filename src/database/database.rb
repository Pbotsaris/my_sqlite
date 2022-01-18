# frozen_string_literal: true

require 'csv'
require 'fileutils'
require_relative './table'

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

  def list_tables
    # skip all other instance variables when listing tables
    tables = instance_variables.reject { |var| var.match?(/@loaded|@path/) } if @loaded
    tables.map { |table| table.to_s[1..table.length] }
  end

  def import_table(name, path)
    return unless _file_exists? path, 'Table'

    destination = "data/#{name}_table.csv"
    FileUtils.cp(path, destination)

    File.open(@path, 'a') do |file|
      file << "#{name}=#{destination}"
    end
    _load_tables([{ name: name, path: destination }])
  end

  private

  def _load_tables(table_files)
    table_files.each do |table_file|
      # using singletooon_class to make attrib avail with attr_accessor
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
