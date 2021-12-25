# frozen_string_literal: true

module ParserConstants
  # Expressions
  module Expression
    SELECT = 'SelectExpression'
    FROM = 'FromExpression'
    UPDATE = 'UpdateExpression'
    INSERT = 'InsertExpression'
    DELETE = 'DeleteExpression'
    VALUES = 'ValuesExpression'
    WHERE = 'WhereExpression'
  end

  module Statement
    EMPTY = 'EmptyStatement'
    EXPRESSION = 'ExpressionStatement'
  end

  module Types
    IDENTIFIER = 'Identifier'
    PARAMS = 'Params'
    ASSIGN = 'Assign'
    NUMERIC_LITERAL = 'NumericLiteral'
    STRING_LITERAL = 'StringLiteral'
  end
end
