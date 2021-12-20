# fronzen_string_literal: true

# Main test runner

require 'json'
require_relative '../src/parser'
require_relative './literal_test'

module TestRunner

  # tests = LiteralTest.tests

  # def execute
  #  puts ast.to_json
  # end

  def test(program, expected)
    #  parser = Parser.new
    #  ast = parser.parse(program)

    assert { program == expected }
  end
end

# tests.each { |test_run| test_run.call(test) }
