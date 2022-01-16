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
      @parser.error ? print_error : evaluate
    end
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
      _expression(statement[:expression])
    end
    pp @request.request
  end

  def _expression(expression)
    return if expression.nil?

    case expression[:type]
    when Expression::SELECT
      _select(expression[:value])
    when Expression::FROM
      _from(expression[:value])
    when Expression::INSERT
      _insert(expression[:value])
    when Expression::VALUES
      _values(expression[:value])
    when Expression::UPDATE
      _update(expression[:value])
    when Expression::SET
      _set(expression[:value])
    when Expression::WHERE
      _where(expression[:value])
    when Expression::DELETE
      _delete
    when Expression::ORDER
      _order(expression[:value])
    end

    _expression expression[:next]
  end

  def _select(node)
    columns = _load_columns(node, [])

    @request.select(columns)
  end

  def _from(node)
    @request.from(node[:name]) if node[:type] == Types::IDENTIFIER
  end

  def _insert(node)
    @request.insert(node[:name])
  end

  def _values(node)
    @request.values(node[:value])
  end

  def _update(node)
    @request.update(node[:name])
  end

  def _set(node)
    columns, values = _load_columns_values_pairs(node, { columns: [], values: [] }).values
    @request.set(columns, values)
  end

  def _where(node)
    columns, values = _load_columns_values_pairs(node, { columns: [], values: [] }).values

    @request.where(columns, values)
  end

  def _delete
    @request.delete
  end

  def _order(node)
    columns = _load_columns(node, [])
    option = _load_order_option(node)
    @request.order(columns, option)
  end

  def _load_columns_values_pairs(node, keypairs)
    return keypairs if node.nil?

    if node[:type] == Types::ASSIGN

      keypairs[:columns] << node[:left][:name]
      keypairs[:values] << node[:right][:value]
    end

    _load_columns_values_pairs(node[:left], keypairs)
    _load_columns_values_pairs(node[:right], keypairs)
  end

  def _load_columns(node, columns)
    return columns if node.nil? || node[:type] != Types::IDENTIFIER

    columns << node[:name]
    _load_columns(node[:left], columns)
  end

  def _load_order_option(node)
    return node[:value] if node[:type] == Types::ORDER_OPTION
    return nil if node.nil?

    _load_order_option(node[:left])
  end
end

# a request
class Request
  attr_reader :request, :valid, :complete
  alias valid? valid
  alias complete? complete

  def initialize
    @request = { table: nil, columns: [], values: [], where: [], order: [], action: nil }
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

  def insert(table)
    @request[:table] = table
    @request[:action] = :insert
  end

  def update(table)
    @request[:table] = table
    @request[:action] = :update
  end

  def delete
    @request[:action] = :delete
  end

  # values = array
  def values(values)
    @request[:values] = values
    @request[:columns] = ['*']
  end

  # columns and values are arrays
  def set(columns, values)
    @request[:columns] = columns
    @request[:values] = values
  end

  def where(columns, values)
    where = columns.each_with_index.map { |column, i| { column: column, term: values[i] } }

    @request[:where] = where
  end

  def order(columns, option)
    @request[:order] = { columns: columns, sort: option ? option.downcase.to_sym : :asc }
  end
end

SQlite.new.run
