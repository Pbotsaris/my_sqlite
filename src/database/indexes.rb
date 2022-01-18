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
