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

  it 'rejects single multi commend' do
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
end
