# frozen_string_literal: true

require_relative '../src/parser/parser'

describe 'Parser Expressions' do
  it 'rejects FROM expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::FROM,
                        next: nil,
                        value: { type: Types::IDENTIFIER,
                                 name: 'books',
                                 left: nil,
                                 right: nil } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('FROM books;')
    expect(ast).to eq(compare)
  end

  it 'rejects INSERT expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::INSERT,
                        next: nil,
                        value: { type: Types::IDENTIFIER,
                                 name: 'table',
                                 left: nil,
                                 right: nil } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('INSERT INTO table;')
    expect(ast).to eq(compare)
  end

  it 'rejects DELETE expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::DELETE,
                        value: nil,
                        next: nil }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('DELETE;')
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
                        value: { type: Types::IDENTIFIER,
                                 name: 'books',
                                 left: nil,
                                 right: nil },
                        next: nil }
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
                        value: { type: Types::IDENTIFIER,
                                 name: 'id',
                                 left: nil,
                                 right: nil },
                        next: nil }
        }
      ]

    }

    parser = Parser.new
    ast = parser.parse('SELECT id ;')
    expect(ast).to eq(compare)
  end

  it 'rejects DELETE expressions with follow up FROM' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::DELETE,
                        value: nil,
                        next: { type: Expression::FROM,
                                value: { type: Types::IDENTIFIER,
                                         name: 'books',
                                         left: nil,
                                         right: nil },
                                next: nil } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('DELETE FROM books;')
    expect(ast).to eq(compare)
  end

  it 'rejects SELECT expression with mutiple identifiers' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SELECT,
                        next: nil,
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

  it 'rejects VALUES expression' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::VALUES,
                        next: nil,
                        value: { type: Types::PARAMS,
                                 value: %w[hello world],
                                 right: nil,
                                 left: nil } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse('VALUES (hello, world) ;')
    expect(ast).to eq(compare)
  end

  it 'rejects WHERE expression with key=pair' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::WHERE,
                        next: nil,
                        value: { type: Types::ASSIGN,
                                 value: '=',
                                 right: { type: Types::STRING_LITERAL,
                                          value: 'seven',
                                          left: nil,
                                          right: nil },
                                 left: { type: Types::IDENTIFIER,
                                         name: 'age',
                                         left: nil,
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("WHERE age = 'seven';")
    expect(ast).to eq(compare)
  end

  it 'rejects WHERE expression with multiple arguments' do
    
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::WHERE,
                        next: nil,
                        value: { type: Types::ASSIGN,
                                 value: '=',
                                 right: { type: Types::STRING_LITERAL,
                                          value: 'seven',
                                          left: nil,
                                          right: nil },
                                 left: { type: Types::IDENTIFIER,
                                         name: 'age',
                                         left: {
                                           type: Types::ASSIGN,
                                           value: '=',
                                           right: {
                                             type: Types::STRING_LITERAL,
                                             value: 'noon',
                                             left: nil,
                                             right: nil
                                           },
                                           left: {
                                             type: Types::IDENTIFIER,
                                             name: 'time',
                                             left: nil,
                                             right: nil
                                           }
                                         },
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("WHERE age = 'seven', time = 'noon';")
    expect(ast).to eq(compare)
  end

  it 'rejects SET expression with multiple arguments' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SET,
                        next: nil,
                        value: { type: Types::ASSIGN,
                                 value: '=',
                                 right: { type: Types::STRING_LITERAL,
                                          value: 'seven',
                                          left: nil,
                                          right: nil },
                                 left: { type: Types::IDENTIFIER,
                                         name: 'age',
                                         left: {
                                           type: Types::ASSIGN,
                                           value: '=',
                                           right: {
                                             type: Types::NUMERIC_LITERAL,
                                             value: 17,
                                             left: nil,
                                             right: nil
                                           },
                                           left: {
                                             type: Types::IDENTIFIER,
                                             name: 'time',
                                             left: nil,
                                             right: nil
                                           }
                                         },
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("SET age = 'seven', time = 17;")
    expect(ast).to eq(compare)
  end

  it 'rejects WHERE expression with follow up expression' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::WHERE,
                        next: { type: Expression::FROM,
                                next: nil,
                                value: { type: Types::IDENTIFIER,
                                         name: 'table',
                                         left: nil,
                                         right: nil } },
                        value: { type: Types::ASSIGN,
                                 value: '=',
                                 right: { type: Types::STRING_LITERAL,
                                          value: 'seven',
                                          left: nil,
                                          right: nil },
                                 left: { type: Types::IDENTIFIER,
                                         name: 'age',
                                         left: nil,
                                         right: nil } } }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("WHERE age = 'seven' FROM table ;")
    expect(ast).to eq(compare)
  end

  it 'rejects multiple expression with mutiple identifiers' do
    compare = {
      type: 'Program',
      body: [
        {
          type: Statement::EXPRESSION,
          expression: { type: Expression::SELECT,
                        next: { type: Expression::FROM,
                                next: nil,
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
end
