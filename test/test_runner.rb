# fronzen_string_literal: true

# Main test runner

require 'pp'
require_relative '../src/parser'
require_relative './literal_test'

#program = 'INSERT INTO students VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);'
#program = 'W
#HERE pedro = "line", dogs = "things"'
program = 'INSERT INTO students VALUES (John, john@johndoe.com, A, https://blog.johndoe.com) ;'
#program = "UPDATE pedro, cars, things, morons"
parser = Parser.new
ast = parser.parse(program)

pp ast
