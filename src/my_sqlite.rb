# frozen_string_literal: true

require 'readline'
require 'pp'
require_relative './parser'

# a class
class SQlite
  def initialize
    @parser = Parser.new
    @ast = {}
  end

  def run
    while (line = Readline.readline('>', true))
      @line = line
      @ast = @parser.parse(line)
      pp @ast
    end
  end
end

SQlite.new.run
