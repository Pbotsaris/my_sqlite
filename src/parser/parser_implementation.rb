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
    when 'JOIN'
      join_expression
    when 'ON'
      on_expression
    when 'VALUES'
      values_expression
    when 'WHERE'
      where_expression
    when 'ORDER'
      order_expression
    when 'SET'
      set_expression
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

  def join_expression
    eat('JOIN')
    arguments(Expression::JOIN)
  end

  def on_expression
    eat('ON')
    arguments(Expression::ON)
  end

  def values_expression
    eat('VALUES')
    arguments(Expression::VALUES)
  end

  def where_expression
    eat('WHERE')
    arguments(Expression::WHERE)
  end

  def set_expression
    eat('SET')
    arguments(Expression::SET)
  end

  def order_expression
    eat('ORDER')
    arguments(Expression::ORDER)
  end

  def arguments(type)
    return nil unless identifier_or_params?

    root = identifier? ? identifier : params

    root = create_keypair root if assign? # check for key=pair arguments

    expression = create_expression(root, type)

    handle_multiple_arguments(root) if multiple_arguments?

    root[:left] = order_option if order_option?

    expression[:next] = self.expression unless end_of_statement?

    expression
  end

  def handle_multiple_arguments(root)
    eat(',')
    while identifier_or_params?
      root = add_to_left(root)

      eat(',') if multiple_arguments?
    end
    root[:left] = order_option if order_option?
  end

  def add_to_left(root)
    left = identifier

    if assign?
      root[:left][:left] = create_keypair(left)
      return root[:left][:left]
    else
      root[:left] = left
    end

    root[:left]
  end

  def create_keypair(left)
    root = assign_operator
    root[:left] = left
    # joins clauses have identifiers as pair. e.g tableA.column=tableB.column
    root[:right] = identifier? ? identifier : literal
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
    return handle_nil if @lookahead.nil?

    case @lookahead[:type]
    when 'NUMBER'
      numeric_literal
    when 'STRING'
      string_literal
    else
      @error = "Unexpected literal: #{@lookahead[:type]}"
      nil
    end
  end

  def handle_nil
    @error = 'Please provide a literal value to the assignment expression'
    { type: Types::NUMERIC_LITERAL, value: '', right: nil, left: nil }
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

  def order_option
    token = eat('ORDER_OPTION')
    { type: Types::ORDER_OPTION, value: token[:value], right: nil, left: nil }
  end

  def assign_operator
    token = eat('ASSIGN')
    { type: Types::ASSIGN, value: token[:value], left: nil, right: nil }
  end

  def eat(type)
    token = @lookahead
    return nil if token.nil?

    message = "Syntax Error: Unexpected end of input '#{token[:type]}'. expected: '#{type}'"
    @error = message unless token && token[:type] == type
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

  def order_option?
    @lookahead && @lookahead[:type] == 'ORDER_OPTION'
  end

  def multiple_arguments?
    @lookahead && @lookahead[:type] == ','
  end

  def end_of_statement?
    @lookahead.nil? || @lookahead == ';'
  end
end
