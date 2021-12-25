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
    expression = self.expression

    eat(';')

    { type: Statement::EXPRESSION, expression: expression }
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
    when 'NUMBER'
      literal
    when 'STRING'
      literal
    end
  end

  def from_expression
    eat('FROM')
    arguments(Expression::FROM)
  end

  def update_expression
    eat('UPDATE')
    arguments(Expression::UPDATE)
  end

  def select_expression
    eat('SELECT')
    arguments(Expression::SELECT)
  end

  def insert_expression
    eat('INSERT')
    arguments(Expression::INSERT)
  end

  def delete_expression
    eat('DELETE')
    create_expression_without_arguments(Expression::DELETE)
  end

  def values_expression
    eat('VALUES')
    arguments(Expression::VALUES)
  end

  def where_expression
    eat('WHERE')
    arguments(Expression::WHERE)
  end

  def arguments(type)
    return nil unless identifier_or_params?

    root = identifier? ? identifier : params

    root = create_keypair root if assign? # check for key=pair arguments

    expression = create_expression(root, type)

    handle_multiple_arguments(root) if @lookahead[:type] == ','

    expression[:next] = self.expression unless @lookahead.nil? || @lookahead == ';'

    expression
  end

  def handle_multiple_arguments(root)
    eat(',')
    while identifier_or_params?
      root = add_to_left(root)

      eat(',') if @lookahead && @lookahead[:type] == ','
    end
  end

  def add_to_left(root)
    left = identifier

    if assign?
      root[:left][:left] = create_keypair(left)
    else
      root[:left] = left
    end
    root[:left]
  end

  def create_keypair(left)
    root = assign_operator
    root[:left] = left
    root[:right] = literal

    root
  end

  def create_expression(value, type)
    { type: type, value: value, next: nil }
  end

  def create_expression_without_arguments(type)
    return { type: type, value: nil, next: nil } if @lookahead[:type] == ';'

    { type: type, value: nil, next: expression }
  end

  def literal
    case @lookahead[:type]
    when 'NUMBER'
      numeric_literal
    when 'STRING'
      string_literal
    else
      puts 'Unexpected literal'
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

  def params
    token = eat('PARAMS')
    values = token[:value].split(',').map(&:strip)

    { type: Types::PARAMS, value: values, left: nil, right: nil }
  end

  def assign_operator
    token = eat('ASSIGN')
    { type: Types::ASSIGN, value: token[:value], left: nil, right: nil }
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

  def identifier_or_params?
    @lookahead && (@lookahead[:type] == 'IDENTIFIER' || @lookahead[:type] == 'PARAMS')
  end

  def identifier?
    @lookahead && @lookahead[:type] == 'IDENTIFIER'
  end

  def assign?
    @lookahead && @lookahead[:type] == 'ASSIGN'
  end
end
