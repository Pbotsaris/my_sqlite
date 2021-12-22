require_relative '../src/parser'

describe 'Parser' do
  it 'rejects Numericliteral' do
    compare = {
      type: 'Program',
      body: [
        {
          type: 'ExpressionStatement',
          expression: { type: 'NumericLiteral', value: 42 }
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
          type: 'ExpressionStatement',
          expression: { type: 'StringLiteral', value: 'hello world' }
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
          type: 'EmptyStatement',
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
          type: 'ExpressionStatement',
          expression: { type: 'StringLiteral', value: 'hello world' }
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
          type: 'ExpressionStatement',
          expression: { type: 'StringLiteral', value: 'hello world' }
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
          type: 'ExpressionStatement',
          expression: { type: 'StringLiteral', value: 'hello world' }
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
          type: 'ExpressionStatement',
          expression: { type: 'NumericLiteral', value: 42 }
        },
        {
          type: 'ExpressionStatement',
          expression: { type: 'StringLiteral', value: 'hello' }
        }
      ]
    }

    parser = Parser.new
    ast = parser.parse("42; 'hello';")
    expect(ast).to eq(compare)
  end

  it 'rejects FROM expressions' do
    compare = {
      type: 'Program',
      body: [
        {
          type: 'ExpressionStatement',
          expression: { type: 'FromExpression',
                        value: { type: 'Identifier', name: 'books' }, next: nil }
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
                        value: { type: 'Identifier', name: 'id' }, next: nil }
        }
      ]

    }

    parser = Parser.new
    ast = parser.parse('SELECT id ;')
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
