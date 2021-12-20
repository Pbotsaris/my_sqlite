# frozen_string_literal: true

SPEC = [

  [/^\s+/, nil],
  [/^\d+/, 'NUMBER'],
  [/^"[^"]*/, 'STRING'],
  [/^'[^']*/, 'STRING']

].freeze

# parser class
class Parser
  def initialize
    @line = ''
    @tokenizer = Tokenizer.new
  end

  def parse(line)
    @tokenizer.load line
    @lookahead = @tokenizer.next_token
    @line = line
    program(line)
  end

  private

  def program(_string)
    { type: 'Program', body: literal }
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

# a class
class Tokenizer
  def initialize
    @cursor = 0
  end

  def load(line)
    @line = line
  end

  def next_token
    return nil unless @cursor < @line.length

    line = @line.slice(@cursor..@line.length).dup

    SPEC.each do |regex, type|
      token_value = match regex, line

      next unless token_value

      return next_token if type.nil? # handles whitespace

      return { type: type, value: token_value }
    end

    puts "Unexpected token #{line}"
  end

  private

  def match(regex, line)
    matched = line.match(regex)
    return nil unless matched

    @cursor += matched[0].length
    matched[0]
  end
end

