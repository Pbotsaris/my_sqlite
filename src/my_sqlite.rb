# frozen_string_literal: true

require 'readline'
require 'pp'
require_relative './parser'
require_relative './request'
require_relative './database'
require_relative './sqlite_implementation'

# a class
class SQlite
  include SQLiteImplementation
  def initialize(path)
    @parser = Parser.new
    @request = Request.new
    @database = Database.new(path)
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
    end
  end

  # this method is used for testing purpuses only
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
      @database.list_table.each { |table| puts table.to_s[1..table.length] }
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
    pp @request.request
  end

  def execute
  end
end

program = SQlite.new('data/nba_test.db')

program.run


