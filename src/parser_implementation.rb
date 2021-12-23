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
    else
      literal
    end
  end

  def from_expression
    eat('FROM')
    single_identifier(Expression::FROM)
  end

  def update_expression
    eat('UPDATE')
    single_identifier(Expression::UPDATE)
  end

  def select_expression
    eat('SELECT')
    multiple_identifiers(Expression::SELECT)
  end

  def insert_expression
    eat('INSERT')
    single_identifier(Expression::INSERT)
  end

  def assignment_expression; end

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
    { type: Types::STRING_LITERAL, value: token[:value].slice!(1..len).dup }
  end

  def numeric_literal
    token = eat('NUMBER')
    { type: Types::NUMERIC_LITERAL, value: token[:value].to_i }
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

  def single_identifier(type)
    unless @lookahead && @lookahead[:type] == 'IDENTIFIER'
      p 'syntax error: FROM requires a table name'
      @error = true
      return nil
    end

    token = eat('IDENTIFIER')
    create_expression(token, type)
  end

  def multiple_identifiers(type)
    token = eat('IDENTIFIER')
    expression = create_expression(token, type)
    identifier = expression[:value]
    eat(',')

    while @lookahead && @lookahead[:type] == 'IDENTIFIER'
      token = eat('IDENTIFIER')
      identifier[:left] = { type: Types::IDENTIFIER, name: token[:value], left: nil, right: nil }
      identifier = identifier[:left]

      eat(',') if @lookahead && @lookahead[:type] == ','
    end

    expression[:left] = self.expression unless @lookahead.nil? || @lookahead == ';'

    expression
  end

  def create_expression(token, type)
    if @lookahead[:type] == ';' || @lookahead[:type] == ','
      { type: type,
        value: { type: Types::IDENTIFIER, name: token[:value], left: nil, right: nil }, left: nil, right: nil }
    else
      { type: type,
        value: { type: Types::IDENTIFER, name: token[:value], left: nil, right: nil }, left: expression,
        right: nil }
    end
  end
end
