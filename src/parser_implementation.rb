# frozen_string_literal: true

require_relative './parser_constants'

#  mixin for the Parser class
module ParserImplementation
  include ParserConstants
  def program
    { type: 'Program', body: @lookahead ? statement_list : {} }
  end

  def statement_list
    list = [statement]

    list.append(statement) while @lookahead

    list
  end

  def statement
    case @lookahead[:type]
    when ';'
      empty_statement
    else
      expression_statement
    end
  end

  def empty_statement
    eat(';')
    { type: Statement::EMPTY, value: nil }
  end

  def expression_statement
    expr = expression
    eat(';')

    { type: Statement::EXPRESSION, expression: expr }
  end

  def expression
    case @lookahead[:type]
    when 'FROM'
      from_expression
    when 'SELECT'
      select_expression
    when 'UPDATE'
      update_expression
    when 'INSERT'
      insert_expression
    when 'DELETE'
      delete_expression
    when 'VALUES'
      values_expression
    when 'WHERE'
      where_expression
    else
      literal
    end
  end

  def from_expression
    eat('FROM')
    single_argument(Expression::FROM)
  end

  def update_expression
    eat('UPDATE')
    single_argument(Expression::UPDATE)
  end

  def select_expression
    eat('SELECT')
    multiple_arguments(Expression::SELECT)
  end

  def insert_expression
    eat('INSERT')
    single_argument(Expression::INSERT)
  end

  def delete_expression
    eat('DELETE')
    no_argument(Expression::DELETE)
  end

  def values_expression
    eat('VALUES')
    parenthesized_argument(Expression::VALUES)
  end

  def where_expression
    eat('WHERE')
    keypairs_argument(Expression::WHERE)
  end

  def assignment_expression; end

  def literal
    case @lookahead[:type]
    when 'NUMBER'
      numeric_literal
    when 'STRING'
      string_literal
    else
      return puts 'Unexpected literal'
      @error = true
      nil
    end
  end

  def string_literal
    token = eat('STRING')
    len = token[:value].length
    { type: Types::STRING_LITERAL, value: token[:value].slice!(1..len).dup, left: nil, right: nil }
  end

  def numeric_literal
    token = eat('NUMBER')
    { type: Types::NUMERIC_LITERAL, value: token[:value].to_i, right: nil, left: nil }
  end

  def identifier
    token = eat('IDENTIFIER')
    { type: Types::IDENTIFIER, name: token[:value], left: nil, right: nil }
  end

  def assign_operator
    token = eat('ASSIGN')
    { type: Types::ASSIGN, value: token[:value], left: nil, right: nil }
  end

  def no_argument(type)
    return create_expression_without_arguments(type) unless @lookahead && @lookahead[:type] == 'IDENTIFIER'

    p "syntax error: #{type} takes no arguments"
    @error = true
    nil
  end

  def single_argument(type)
    unless @lookahead && @lookahead[:type] == 'IDENTIFIER'
      p "syntax error: #{type} requires arguments"
      @error = true
      return nil
    end

    identifier = self.identifier
    create_expression(identifier, type)
  end

  def parenthesized_argument(type)
    eat('()')
    expression = multiple_arguments(type)
    eat('()')
    expression
  end

  def multiple_arguments(type)
    identifier = self.identifier
    expression = create_expression(identifier, type)
    p expression
    identifier = expression[:value]
    eat(',')

    parse_through_multiple_arguments(identifier)

    expression[:left] = self.expression unless @lookahead.nil? || @lookahead == ';'

    expression
  end

  def keypairs_argument(type)
    left = identifier
    root = assign_operator
    right = @lookahead[:type] == 'STRING' ? string_literal : numeric_literal
    expression = create_expression(root, type)
    expression[:value][:left] = left

    p right

    expression[:value][:right] =  right

    #  left = create_node(eat('IDENTIFIER'),  Types::IDENTIFIER)
    #  root_token = eat('ASSIGN')
    #  expression = create_expression(root_token, type, Types::ASSIGN)
    #  expression[:value][:left] = left
    #  expression[:value][:right] = string_literal

    #  expression[:value][:left][:left] = keypairs_argument(type) if !@lookahead.nil? && @lookahead == 'IDENTIFIER'
    expression
  end

  def parse_through_multiple_arguments(identifier)
    while @lookahead && @lookahead[:type] == 'IDENTIFIER'
      identifier[:left] = self.identifier
      identifier = identifier[:left]

      eat(',') if @lookahead && @lookahead[:type] == ','
    end
  end

  def create_expression(value, type)
    expression = { type: type, value: value, left: nil, right: nil }

    return expression if @lookahead[:type] == ';' || @lookahead[:type] == ','

    expression[:left] = self.expression

    expression
  end

  def create_expression_without_arguments(type)
    return { type: type, value: nil, left: nil, right: nil } if @lookahead[:type] == ';'

    { type: type, value: nil, left: expression, right: nil }
  end

  def eat(type)
    token = @lookahead
    unless token && token[:type] == type
      puts "Unexpected end of input, expected: #{type}"
      @error = true
    end

    @lookahead = @tokenizer.next_token

    token
  end
end
