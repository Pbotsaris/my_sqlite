# frozen_string_literal: true

require_relative './parser_implementation'
require_relative './tokenizer_implementation'

# Parser class
class Parser
  attr_accessor :error

  include ParserImplementation

  def initialize
    @line = ''
    @tokenizer = Tokenizer.new
    @error = false
  end

  def parse(line)
    @tokenizer.load line
    @lookahead = @tokenizer.next_token
    @line = line
    program
  end
end

# Tokenizer class
class Tokenizer
  include TokenizerImplementation

  def load(line)
    @cursor = 0
    @line = line
  end

  def next_token
    return nil unless @cursor < @line.length

    line = @line.slice(@cursor..@line.length).dup

    SPEC.each do |regex, type|
      token_value = match(regex, line)

      next unless token_value
      return next_token if type.nil? # skip whitespaces & comments

      @cursor += 1 if type == 'STRING' # skip parenthesis
      @cursor += 2 if type == 'PARAMS' # skip parenthesis

      return { type: type, value: token_value }
    end

    p "Unexpected token #{line}"
    nil
  end
end
