# frozen_string_literal: true

require_relative '../src/parser'
require_relative '../src/parser_constants'

Statement = ParserConstants::Statement
Expression = ParserConstants::Expression
Types = ParserConstants::Types

describe 'Parser Literals' do
  include ParserConstants

  it 'rejects Numericliteral' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::NUMERIC_LITERAL,
                        value: 42,
                        left: nil,
                        right: nil }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('42;')
    expect(ast).to eq(compare)
  end

  it 'rejects StringLiteral with spaces' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::STRING_LITERAL,
                        value: 'hello world',
                        left: nil,
                        right: nil }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('     "hello world";')
    expect(ast).to eq(compare)
  end

  it 'rejects EmptyStatement' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EMPTY,
          value: nil
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse(';')
    expect(ast).to eq(compare)
  end

  it 'rejects StringLiteral double quotes' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::STRING_LITERAL,
                        value: 'hello world',
                        left: nil,
                        right: nil
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('"hello world";')
    expect(ast).to eq(compare)
  end

  it 'rejects single line commend' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::STRING_LITERAL,
                        value: 'hello world',
                        left: nil,
                        right: nil
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("
    --comments
   'hello world';")
    expect(ast).to eq(compare)
  end

  it 'rejects single comments' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::STRING_LITERAL,
                        value: 'hello world',
                        left: nil,
                        right: nil
          }
        }
      ]

    }

    parser = Parser.new
    ast = parser.parse("
    /*
    * multiline comment
    */
   'hello world';")
    expect(ast).to eq(compare)
  end

  it 'rejects multiple statements' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::NUMERIC_LITERAL,
                        value: 42,
                        left: nil,
                        right: nil
          }
        },
        {
          type: Statement::EXPRESSION,
          expression: { type: Types::STRING_LITERAL,
                        value: 'hello',
                        left: nil,
                        right: nil
          }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("42; 'hello';")
    expect(ast).to eq(compare)
  end
end
