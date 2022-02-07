# My SQLite

A naive implementation of the SQlite. The entry point to the program is the file `my_sqlite.rb` in the `src` directory. To run use ruby:

    ruby src/my_sqlite.rb

## Basic Usage
There are two ways you can use `my_sqlite` 

1. loading a table from a CSV or 
2. querying a CSV file directly.

Loading your tables from a CSV is the more performant because the program will index the table when you import the CSV. Then, when you run a query the table is already indexed and ready to go. Importing will also create a copy of the CSV file in the `data/` directory so editing a table will NOT modify your original csv file.

When you query a csv file directly however, the program has to create a temporary table and index for this table at every request. This slows things down a lot. Updating, delete and insert will
modify your original CSV file.

## Loading the database from a file
A database can be loaded from a file with as many table as you want. To load a database you must pass in as the firt argument when running the program.

    ruby src/my_sqlite.rb data/database_name.db

Database files are simple text files containing `key=pair` values where the `key` is the name of a table and `pair` is the path to the CSV. Example below:

```
player=data/nba_players.csv
player_data=data/nba_player_data.csv
```

 The program will create a temporary database and persist to `temp.db` when you launch it without specifying a database to load.

## Importing a table from a CSV file

You can import a table from csv using the following command:

    sqlite>import table_name path/to/csv;

So if you want to import the table `players` from `nba_players.csv` run:

    sqlite>import players data/nba_players.csv;

You can use the `table` command to list the tables in the current database:

    sqlite> tables
    
    players

Note that when you import tables to a database it will **COPY** the csv file to the `data/` directory.

## Running 

When you import a table you don't need to provide the full path of a CSV to run a query:

    sqlite>import players data/nba_players.csv
    sqlite>SELECT * FROM players WHERE Player='Nelson Bobb';
    Nelson Bobb | 183 | 77 | Temple University | 1924 | Philadelphia | Pennsylvania |

To run a query directly on a CSV file you must provide the path to the file:
    
    sqlite>SELECT * FROM data/players_table.csv WHERE Player='Nelson Bobb';
    Nelson Bobb | 183 | 77 | Temple University | 1924 | Philadelphia | Pennsylvania |

## Examples

### SELECT and FROM 

SELECT column1, column2 [...] FROM a table.

    sqlite>SELECT Player, height FROM players;

### ORDER BY

Orders the query result by a given column. You can order as `ASC` or `DESC`.
    
    sqlite>SELECT * FROM players ORDER BY height DESC;

### WHERE

Only returns rows where column = criteria matches.

    sqlite>SELECT * FROM players WHERE Player='Nelson Bobb';


### INSERT INTO and VALUES

Inserts a column.  Number of columns must match items in VALUES

    sqlite>INSERT INTO players VALUES(Maradonna, 190, 50, BsAs University, 1980, Buenos Aires, BS);

### UPDATE

Updates a certain column of a row. Normally used with a `WHERE` clause to find the row to update.

    sqlite>UPDATE players SET height=190, collage='NYU' WHERE Player='Nelson Bobb';

### DELETE

Deletes a row from a table.
    sqlite> DELETE FROM players WHERE Player='Nelson Bobb'

### JOIN
  
Joins two table together. You can join imported tables with external csv files together as in the example below:

     sqlite> SELECT * FROM player_test JOIN data/nba_player_data.csv ON Player=name;

Or you could just import the other table in and run the join:

    sqlite> import player_data data/nba_player_data.csv
    sqlite> SELECT * FROM players JOIN player_data ON Player=name;

Note that providing the columns to create the join you can use both syntaxes `columnA=columnB` or `tableA.column=tableB=column`. Both will work. Example:

    sqlite> SELECT * FROM players JOIN player_data ON players.Player=player_data.name;

## Indexing

  `my_sqlite` indexes the tables using a [trie](https://en.wikipedia.org/wiki/Trie#:~:text=In%20computer%20science%2C%20a%20trie,key%2C%20but%20by%20individual%20characters.) data structure. Each column of a table has it's own trie to keep track of the indexes.

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
