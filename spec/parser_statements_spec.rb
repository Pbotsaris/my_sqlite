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

  it 'rejects statement with UPDATE and SET' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: {
            type: Expression::UPDATE,
            value: {
              type: Types::IDENTIFIER,
              name: 'students',
              left: nil,
              right: nil
            }, next: {
              type: Expression::SET,

              value: {
                type: Types::ASSIGN,
                value: '=',
                left: {
                  type: Types::IDENTIFIER,
                  name: 'email',
                  right: nil,
                  left: {
                    type: Types::ASSIGN,
                    value: '=',

                    left: {
                      type: Types::IDENTIFIER,
                      name: 'blog',
                      right: nil,
                      left: nil
                    },
                    right: {
                      type: Types::STRING_LITERAL,
                      value: 'https://blog.janedoe.com',
                      left: nil,
                      right: nil
                    }
                  }
                },
                right: {
                  type: Types::STRING_LITERAL,
                  value: 'jane@janedoe.com',
                  left: nil,
                  right: nil
                }
              },
              next: {
                type: Expression::WHERE,
                next: nil,
                value: {
                  type: Types::ASSIGN,
                  value: '=',
                  left: {
                    type: Types::IDENTIFIER,
                    name: 'name',
                    right: nil,
                    left: nil
                  },
                  right: {
                    type: Types::STRING_LITERAL,
                    value: 'Jane',
                    left: nil,
                    right: nil
                  }
                }
              }
            }
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';")

    expect(ast).to eq(compare)
  end

  it 'rejects statement with INSERT and VALUES' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: {
            type: Expression::SELECT,
            value: {
              type: Types::IDENTIFIER,
              name: '*',
              left: nil,
              right: nil
            },
            next: nil
          }
        },
        {
          type: Statement::EXPRESSION,
          expression: {
            type: Expression::WHERE,
            value: {
              type: Types::ASSIGN,
              value: '=',
              left: {
                type: Types::IDENTIFIER,
                name: 'age',
                left: nil,
                right: nil
              },
              right: {
                type: Types::NUMERIC_LITERAL,
                value: 17,
                right: nil,
                left: nil
              }
            },
            next: nil
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('SELECT *; WHERE age=17;')

    expect(ast).to eq(compare)
  end
end
