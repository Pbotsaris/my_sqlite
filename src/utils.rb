# frozen_string_literal: true

# Utility module
module Utils
  # Helper module to print query results
  module Printer
    def print(data, columns)
      data.each do |row|
        block = proc { |column, i| i.zero? ? print("| #{row[column]} |") : print(" #{row[column]} |") }

        columns[0] == '*' ? _print_all(row) : columns.each_with_index(&block)

        puts ''
      end
    end

    def print_table_array(table, cols)
      table.each do |row|
        row.each_with_index do |column, i|
          if cols.include?(i)
            i.zero? ? print("| #{column} |") : print(" #{column} |")
          end
        end
      end
      puts ''
    end
  end

  def _print_all(row)
    row.each_with_index { |column, i| i.zero? ? print("| #{column[1]} |") : print(" #{column[1]} |") }
  end
end
