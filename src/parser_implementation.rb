# frozen_string_literal: true

#  mixin for the Parser class
module ParserImplementation
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
    { type: 'EmptyStatement', value: nil }
  end

  def expression_statement
    expr = expression
    eat(';')

    { type: 'ExpressionStatement', expression: expr }
  end

  # SELECT * FROM ciences;

  def expression
    case @lookahead[:type]
    when 'FROM'
      from_expression
    when 'SELECT'
      select_expression
    else
      literal
    end
  end

  def from_expression
    eat('FROM')
    single_identifier('FromExpression')
  end

  def select_expression
    eat('SELECT')
    single_identifier('SelectExpression')
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
    { type: 'StringLiteral', value: token[:value].slice!(1..len).dup }
  end

  def numeric_literal
    token = eat('NUMBER')
    { type: 'NumericLiteral', value: token[:value].to_i }
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

  def create_expression(token, type)
    if @lookahead[:type] == ';'
      { type: type, value: { type: 'Identifier', name: token[:value] }, next: nil }
    else
      { type: type, value: { type: 'Identifier', name: token[:value] }, next: expression }
    end
  end
end
