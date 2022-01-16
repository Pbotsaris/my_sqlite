# frozen_string_literal: true

require 'readline'
require 'pp'
require_relative './parser'
require_relative './request'
require_relative './sqlite_implementation'

# a class
class SQlite
  include SQLiteImplementation
  def initialize
    @parser = Parser.new
    @request = Request.new
    @ast = {}
  end

  def run
    while (line = Readline.readline('>', true))
      @request.reset
      break if quit? line

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
    line.match?(/^quit/)
  end

  def print_error
    p @parser.error
    @parser.error = false
  end

  def evaluate
    @ast[:body].each do |statement|
      expression(statement[:expression])
    end
#    pp @request.request
  end
end

# SQlite.new.run
