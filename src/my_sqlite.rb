# frozen_string_literal: true

require 'readline'
require 'pp'
require_relative './parser/parser'
require_relative './request'
require_relative './database/database'
require_relative './sqlite_implementation'

# a class
class SQlite
  include SQLiteImplementation
  def initialize(path)
    @parser = Parser.new
    @request = Request.new(path)
    @ast = {}
  end

  def run
    while (line = Readline.readline('sqlite>', true))
      @request.reset
      break if quit? line

      next if table? line

      next if import_table? line

      @ast = @parser.parse(line)
      @parser.error ? print_error : evaluate

      @request.run
    end
  end

  # this method is used for testing requests
  def test(ast)
    @ast = ast
    evaluate
    @request
  end

  def quit?(line)
    line.match?(/^quit|^.quit/)
  end

  def table?(line)
    if line.match?(/^tables|^.tables/)
      puts '', 'Tables:'
      @database.list_tables.each { |table| puts table }
      puts ''
      return true
    end
    false
  end

  def import_table?(line)
    if line.match?(/^import|^.import/)
      line = line.split(' ')
      @database.import_table line[1], line[2]
      return true
    end
    false
  end

  def print_error
    p @parser.error
    @parser.error = false
  end

  def evaluate
    @ast[:body].each do |statement|
      expression(statement[:expression])
    end
  end
end

program = SQlite.new('data/nba_test.db')

program.run
