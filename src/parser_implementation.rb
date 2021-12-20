# frozen_string_literal: true

#  mixin for the Parser class
module ParserImplementation
  def program
    { type: 'Program', body: @lookahead ? literal : {} }
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
    { type: 'NumericLiteral', value: token[:value] }
  end

  def eat(type)
    token = @lookahead
    puts "Unexpected end of input, expected: #{type}" unless token
    puts "Unexpected end of input, expected: #{type}" unless token[:type] == type

    @lookahead = @tokenizer.next_token

    token
  end
end
