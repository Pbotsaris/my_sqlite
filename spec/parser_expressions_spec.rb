# frozen_string_literal: true

require_relative '../src/parser'

describe 'Parser Expressions' do
  it 'rejects FROM expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::FROM,
                        value: { type: Types::IDENTIFIER, name: 'books', left: nil, right: nil },
                        left: nil, right: nil }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('FROM books;')
    expect(ast).to eq(compare)
  end

  it 'rejects error when FROM lacks a table name argument' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: nil
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('FROM ;')
    expect(ast).to eq(compare)
  end

  it 'rejects UPDATE expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::UPDATE,
                        value: { type: Types::IDENTIFIER, name: 'books', left: nil, right: nil },
                        left: nil, right: nil }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('UPDATE books;')
    expect(ast).to eq(compare)
  end

  it 'rejects SELECT expression' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SELECT,
                        value: { type: Types::IDENTIFIER, name: 'id', left: nil, right: nil },
                        left: nil, right: nil }
        }
      ]

    }

    parser = Parser.new
    ast = parser.parse('SELECT id ;')
    expect(ast).to eq(compare)
  end

  it 'rejects SELECT expression with mutiple identifiers' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SELECT,
                        left: nil,
                        right: nil,
                        value: { type: Types::IDENTIFIER,
                                 name: 'id',
                                 right: nil,
                                 left: { type: Types::IDENTIFIER,
                                         name: 'name',
                                         left: nil,
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('SELECT id, name ;')
    expect(ast).to eq(compare)
  end

  it 'rejects multiple expression with mutiple identifiers' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SELECT,
                        right: nil,
                        left: { type: Expression::FROM,
                                right: nil,
                                left: nil,
                                value: { type: Types::IDENTIFIER,
                                         name: 'table',
                                         right: nil,
                                         left: nil } },
                        value: { type: Types::IDENTIFIER,
                                 name: 'id',
                                 right: nil,
                                 left: { type: Types::IDENTIFIER,
                                         name: 'name',
                                         left: nil,
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('SELECT id, name FROM table ;')
    expect(ast).to eq(compare)
  end

  #  it 'rejects single line commend' do
  #    compare = {
  #      type: 'Program',
  #      body: [
  #        {
  #          type: 'ExpressionStatement',
  #          expression: { type: 'AssignementExpression',
  #                        operator: '=',
  #                        left: { type: 'Identifier', name: 'x' },
  #                        right: { type: 'NumericLiteral', value: 32 } }
  #        }
  #      ]
  #    }
  #
  #    parser = Parser.new
  #    ast = parser.parse('x = 32;')
  #    expect(ast).to eq(compare)
  #  end
end
