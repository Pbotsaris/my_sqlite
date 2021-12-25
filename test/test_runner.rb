# fronzen_string_literal: true

# Main test runner

require 'json'
require_relative '../src/parser'
require_relative './literal_test'


  # tests = LiteralTest.tests

  # def execute
  #  puts ast.to_json
  # end

      program = "WHERE pedro = 'hello', age = 'seven' ;"
      parser = Parser.new
      ast = parser.parse(program)

      p ast


# tests.each { |test_run| test_run.call(test) }
