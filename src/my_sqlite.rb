# frozen_string_literal: true

require 'readline'
require 'pp'
require_relative './parser'
require_relative './parser_constants'

# a class
class SQlite
  include ParserConstants
  def initialize
    @parser = Parser.new
    @request = Request.new
    @ast = {}
  end

  def run
    while (line = Readline.readline('>', true))
      break if quit? line

      @ast = @parser.parse(line)
      evaluate
      pp @request.request
    end
  end

  def quit?(line)
    line.match?(/^quit/)
  end

  def evaluate
    @ast[:body].each do |statement|
      _expression(statement[:expression])
    end
  end

  def _expression(expression)
    return if expression.nil?

    case expression[:type]
    when Expression::SELECT
      _select(expression[:value])
    when Expression::FROM
      _from(expression[:value])
    end

    _expression expression[:next]
  end

  def _select(value)
    columns = _load_columns(value, [])
    @request.select(columns)
  end

  def _from(value)
    @request.from(value[:name]) if value[:type] == Types::IDENTIFIER
  end

  def _load_columns(value, columns)
    return columns if value.nil?

    columns << value[:name]
    load_columns(value[:left], columns)
  end
end

# a request
class Request
  attr_reader :request, :valid, :complete
  alias valid? valid
  alias complete? complete

  def initialize
    @request = { table: nil, columns: [], where: nil, action: nil }
    @valid = true
    @complete = false
  end

  def from(table)
    @request[:table] = table
  end

  # columns is an array
  def select(columns)
    @request[:columns] = columns
    @request[:action] = :select
  end

  def where(term)
    @request[:where] = term
  end
end

SQlite.new.run
