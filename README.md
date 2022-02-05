# My SQLite

A naive implementation of the SQlite.

## Parser

The program provides basic parsing for the following SQL clauses `UPDATE`, `INSERT`, `WHERE`, `VALUES`, `SET`, `FROM`, `DELETE`. The parser is capable of handling multiple statements as well as comments.

### Example of the AST schema:

```
ast = Parser.new.parse('INSERT INTO students VALUES (John, john@johndoe.com, A, https://blog.johndoe.com) ;')
p ast

{
  type: 'Program',
  body: [
    {
      type: 'ExpressionStatement',
      expression: {
        type: 'InsertExpression',
        value: {
          type: 'Identifier',
          name: 'students',
          left: nil,
          right: nil
        }, next: {
          type: 'ValueExpression',
          next: nil,
          value: {
            type: 'Params',
            value: ['John', 'john@johndoe.com', 'A', 'https://blog.johndoe.com'],
            left: nil,
            right: nil
          }
        }
      }
    }
  ]
}
```

### With `key = pair` clause arguments:

```
ast = Parser.new.parse("WHERE age = 'seven', time = 'noon';")
p ast
{
      type: 'Program',
      body: [
        {
          type: 'ExpressionStatement',
          expression: {
            type: 'WhereExpression',
            next: nil,
            value: { type: 'Assign',
                     value: '=',
                     right: {
                       type: 'StringLiteral',
                       value: 'seven',
                       left: nil,
                       right: nil
                     },
                     left: {
                       type: 'Identifier',
                       name: 'age',
                       left: {
                         type: 'Assign',
                         value: '=',
                         right: {
                           type: 'StringLiteral',
                           value: 'noon',
                           left: nil,
                           right: nil
                         },
                         left: {
                           type: 'Identifier',
                           name: 'time',
                           left: nil,
                           right: nil
                         }
                       },
               right: nil
              } 
            }
          }
        }
      ]
    }
```

### Empty statements:
 
 ```
ast = Parser.new.parse(';')
p ast

{
  type: 'Program',
  body: [
    {
      type: 'EmptyStatement',
      value: nil
    }
  ]
}
 ```

### Multiple statements:

```
ast = Parser.new.parse('42; "hello";')
p ast

{
  type: 'Program',
  body: [
    {
      type: 'ExpressionStatement',
      expression: { type: 'Numericliteral',
                    value: 42,
                    right: nil
                      left: nil,
      }
    },
    {
      type: Statement::EXPRESSION,
      expression: { type: Types::'StringLiteral',
                    value: 'hello',
                    left: nil,
                    right: nil
      }
    }
  ]
}
```

### Comments:

```
ast = Parser.new.parse("
    --comments
   'hello world';")
p ast

{
  type: 'Program',
  body: [
    {
      type: 'ExpressionStatement',
      expression: { type: 'StringLiteral',
                    value: 'hello world',
                    left: nil,
                    right: nil
      }
    }
  ]

}
```

## Installing gems

First, make sure you have ruby installed. Refer to this [link](https://www.ruby-lang.org/en/documentation/installation/) for more information.

To run test using [rspec](https://rspec.info/) make sure you are in the root directory if this project and install the gems in `Gemfile`:

      bundle install


## Running tests

Tests can be ran using the following command:

      ./bin/rspec


## Writting tests

Tests are located in the `spec/` directory. Create a new file `xxxxx_spec.rb` where `xxxxx` is unique name to your test file. Tests are written inside a describe block like so:


```
describe 'A describing this group of tests' do

  it 'a description of what your test is rejecting' do
  # your test yere
  end

 it 'another test' do
  # your test yere
  end
end

```
more information on rspec [here](https://rspec.info/).
