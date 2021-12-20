#fronzen_string_literal: true

# Main test runner

require_relative '../src/parser'
require 'json'

parser = Parser.new
program = "         23"

ast = parser.parse(program)

puts ast.to_json
