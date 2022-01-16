# frozen_string_literal: true

require_relative './parser_constants'

# main sql class implementation
module SQLiteImplementation
  include ParserConstants

  def expression(expression)
    return if expression.nil?

    case expression[:type]
    when Expression::SELECT
      select(expression[:value])
    when Expression::FROM
      from(expression[:value])
    when Expression::INSERT
      insert(expression[:value])
    when Expression::VALUES
      values(expression[:value])
    when Expression::UPDATE
      update(expression[:value])
    when Expression::SET
      set(expression[:value])
    when Expression::WHERE
      where(expression[:value])
    when Expression::DELETE
      delete
    when Expression::JOIN
      join(expression[:value])
    when Expression::ON
      on(expression[:value])
    when Expression::ORDER
      order(expression[:value])
    end

    expression expression[:next]
  end

  def select(node)
    columns = load_columns(node, [])

    @request.select(columns)
  end

  def from(node)
    @request.from(node[:name]) if node[:type] == Types::IDENTIFIER
  end

  def insert(node)
    @request.insert(node[:name])
  end

  def values(node)
    @request.values(node[:value])
  end

  def update(node)
    @request.update(node[:name])
  end

  def set(node)
    columns, values = load_columns_values_pairs(node, { columns: [], values: [] }).values
    @request.set(columns, values)
  end

  def where(node)
    columns, values = load_columns_values_pairs(node, { columns: [], values: [] }).values

    @request.where(columns, values)
  end

  def delete
    @request.delete
  end

  def join(node)
    @request.join(node[:name])
  end

  def on(node)
    columns = load_columns(node, [])
    @request.on(columns)
  end

  def order(node)
    columns = load_columns(node, [])
    option = load_order_option(node)
    @request.order(columns, option)
  end

  def load_columns_values_pairs(node, keypairs)
    return keypairs if node.nil?

    if node[:type] == Types::ASSIGN

      keypairs[:columns] << node[:left][:name]
      keypairs[:values] << node[:right][:value]
    end

    load_columns_values_pairs(node[:left], keypairs)
    load_columns_values_pairs(node[:right], keypairs)
  end

  def load_columns(node, columns)
    return columns if node.nil? || node[:type] != Types::IDENTIFIER

    columns << node[:name]
    load_columns(node[:left], columns)
  end

  def load_order_option(node)
    return nil if node.nil?
    return node[:value] if node[:type] == Types::ORDER_OPTION

    load_order_option(node[:left])
  end
end
