# frozen_string_literal: true

require_relative '../src/parser'

describe 'Parser Expressions' do
  it 'rejects FROM expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: 'ExpressionStatement',
          expression: { type: 'FromExpression',
                        value: { type: 'Identifier', name: 'books', left: nil, right: nil },
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
          type: 'ExpressionStatement',
          expression: nil
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('FROM ;')
    expect(ast).to eq(compare)
  end

  it 'rejects SELECT expression' do
    compare = {
      type: 'Program',
      body: [
        {
          type: 'ExpressionStatement',
          expression: { type: 'SelectExpression',
                        value: { type: 'Identifier', name: 'id', left: nil, right: nil },
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
          type: 'ExpressionStatement',
          expression: { type: 'SelectExpression',
                        left: nil,
                        right: nil,
                        value: { type: 'Identifier',
                                 name: 'id',
                                 right: nil,
                                 left: { type: 'Identifier',
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
