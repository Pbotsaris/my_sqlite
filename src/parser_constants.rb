module ParserConstants 
  # Expressions
  module Expression
   SELECT = 'SelectExpression'
   FROM = 'FromExpression'
   UPDATE = 'UpdateExpression'
   INSERT = 'Insert Expression'
  end

  module Statement
   EMPTY = 'EmptyStatement'
   EXPRESSION = 'ExpressionStatement'
  end

  module Types
   IDENTIFIER = 'Identifier'
   NUMERIC_LITERAL = 'NumericLiteral'
   STRING_LITERAL = 'StringLiteral'
  end
end
