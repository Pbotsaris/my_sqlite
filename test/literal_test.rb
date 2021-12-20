# frozen_string_literal: true

# Test Literals
module LiteralTest
  def tests
    [method(:test_numeric), method(:test_string_double), method(:test_string_single)]
  end

  def test_numeric(test = method(:test))
    ast = {
      type: 'Program',
      body: {
        type: 'NumericLiteral',
        value: 42
      }
    }

    test.call('42', ast)
  end

  def test_string_double(test = method(:test))
    ast = {
      type: 'Program',
      body: {
        type: 'StringLiteral',
        value: 'hello'
      }
    }

    test.call('"hello"', ast)
  end

  def test_string_single(test = method(:test))
    ast = {
      type: 'Program',
      body: {
        type: 'StringLiteral',
        value: 'hello'
      }
    }

    test.call("'hello'", ast)
  end
end
