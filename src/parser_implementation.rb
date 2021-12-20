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
    expression_statement
  end

  def expression_statement
    expr = expression
    eat(';')

    { type: 'ExpressionStatement', expression: expr }
  end

  def expression
    literal
  end

  def literal
    case @lookahead[:type]
    when 'NUMBER'
      numeric_literal
    when 'STRING'
      string_literal
    else
      puts 'Unexpected literal'
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
    puts "Unexpected end of input, expected: #{type}" unless token
    puts "Unexpected end of input, expected: #{type}" unless token[:type] == type

    @lookahead = @tokenizer.next_token

    token
  end
end
