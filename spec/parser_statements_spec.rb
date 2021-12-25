# frozen_string_literal: true

require_relative '../src/parser'
require 'pp'


describe 'Parser Statements' do
  it 'rejects statement with INSERT and VALUES' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: {
            type: Expression::INSERT,
            value: {
              type: Types::IDENTIFIER,
              name: 'students',
              left: nil,
              right: nil
            }, next: {
              type: Expression::VALUES,
              next: nil,
              value: {
                type: Types::PARAMS,
                value: ['John', 'john@johndoe.com', 'A', 'https://blog.johndoe.com'],
                left: nil,
                right: nil
              }
            }
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('INSERT INTO students VALUES (John, john@johndoe.com, A, https://blog.johndoe.com) ;')

    expect(ast).to eq(compare)
  end
end
