# frozen_string_literal: true

require 'readline'
require_relative './parser/parser'
require_relative './request'
require_relative './database/database'
require_relative './sqlite_implementation'

# a class
class SQlite
  include SQLiteImplementation
  def initialize(path)
    @parser = Parser.new
    @database = path.nil? ? nil : Database.new(path)
    @request = Request.new(@database)
    @ast = {}
  end

  def run
    database?
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
      tables = @database&.list_tables
      tables&.each { |table| puts table }
      puts 'Database and/or tables not loaded.' if tables.nil?
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

  def database?
    return if @database

    puts "database not loaded. creating new 'temp.db'...\nYou can import from csv using the `import <path-to-csv>'"

    File.open('data/temp.db', 'w') { |f| f.write('') }

    @database = Database.new('data/temp.db')
    @request.load_database(@database)
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

program = SQlite.new(ARGV.empty? ? nil : ARGV[0])
program.run
