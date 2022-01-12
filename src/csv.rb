require 'csv'
require_relative './trie'

# table class
class Indexes
  def load(path, headers)
    file = File.read path
    data = CSV.parse file, headers: true
    _set_columns(headers)
    _read_column(data, headers)
  end

  def find(column, name)
    found = instance_variable_get("@#{column}").find name
    found.id
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

# Table class
class Table
  attr_reader :headers

  def initialize(path)
    @path = path
    @headers = _load_headers path
    @indexes = Indexes.new
    @indexes.load @path, @headers
  end

  def where(column, term)
    indexes = @indexes.find(column, term).map(&:to_i)
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
    lines = []

    indexes.each do |index|
      # +1 skips headers
      (index - prev + 1).times { file.gets }

      lines << file.gets
      prev = index
    end
    lines
  end

  def _load_headers(path)
    headers = CSV.open(path, &:readline)
    headers.reject(&:nil?)
  end
end

# CSV reader
class Database
end

nba_players = Table.new './data/nba_players.csv'
p nba_players.where('Player', 'Cliff Barker')
# p table.find('Player', 'Cliff Barker')
# p table.column_names
