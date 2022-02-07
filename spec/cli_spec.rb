# frozen_string_literal: true

require_relative '../src/my_sqlite'
require_relative '../src/parser/parser'

# tests for CLI interface
describe 'CLI Select' do
  it 'rejects SELECT columns FROM table ORDER BY column' do
    compare = { table: 'students',
                columns: %w[id name],
                values: [],
                where: [],
                order: { columns: %w[name], sort: :asc }, # :asc is default
                join: { table: nil, columns: [] },
                action: :select }

    parser = Parser.new
    ast = parser.parse('SELECT id, name FROM students ORDER BY name;')

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

  it 'rejects SELECT columns FROM table ORDER BY column DESC' do
    compare = { table: 'students',
                columns: %w[id name],
                values: [],
                where: [],
                order: { columns: %w[name], sort: :desc },
                join: { table: nil, columns: [] },
                action: :select }

    parser = Parser.new
    ast = parser.parse('SELECT id, name FROM students ORDER BY name DESC;')

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

  it 'rejects SELECT columns FROM table ORDER BY one_column, two_columns DESC' do
    compare = { table: 'students',
                columns: %w[id name],
                values: [],
                where: [],
                order: { columns: %w[name id], sort: :desc },
                join: { table: nil, columns: [] },
                action: :select }

    parser = Parser.new
    ast = parser.parse('SELECT id, name FROM students ORDER BY name, id DESC;')

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

  it 'rejects SELECT columns FROM table WHERE key=pair' do
    compare = { table: 'students',
                columns: %w[id name],
                values: [],
                where: [{ column: 'name', term: 'Khalil' }, { column: 'id', term: '10' }],
                order: { columns: nil, sort: :asc }, # :asc is default
                join: { table: nil, columns: [] },
                action: :select }

    parser = Parser.new
    ast = parser.parse("SELECT id, name FROM students WHERE name= 'Khalil', id= '10' ;")

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)

    expect(request.request).to eq(compare)
  end

  it 'rejects SELECT columns FROM table JOIN table ON column, column' do
    compare = { table: 'students',
                columns: %w[id name],
                values: [],
                where: [],
                order: { columns: nil, sort: :asc }, # :asc is default
                join: { table: 'homework', columns: %w[id class] },
                action: :join }

    parser = Parser.new
    ast = parser.parse('SELECT id, name FROM students JOIN homework ON id, class;')

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)

    expect(request.request).to eq(compare)
  end
end

describe 'CLI insert delete update' do
  it 'INSERT INTO table VALUES (value, value, value)' do
    compare = { table: 'students',
                columns: ['*'],
                values: %w[Khalil 19 Israel],
                where: [],
                order: { columns: nil, sort: :asc }, # :asc is default
                join: { table: nil, columns: [] },
                action: :insert }

    parser = Parser.new
    ast = parser.parse('INSERT INTO students values(Khalil, 19, Israel);')

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

  it 'DELETE FROM table WHERE key=pair' do
    compare = { table: 'students',
                columns: ['*'],
                values: [],
                where: [{ column: 'name', term: 'Khalil' }],
                order: { columns: nil, sort: :asc }, # :asc is default
                join: { table: nil, columns: [] },
                action: :delete }

    parser = Parser.new
    ast = parser.parse("DELETE FROM students WHERE name='Khalil';")

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

  it 'UPDATE students SET key=pair, key=pair WHERE key=pair' do
    compare = { table: 'students',
                columns: %w[email age],
                values: ['k@email.com', '28'],
                where: [{ column: 'name', term: 'Khalil' }],
                order: { columns: nil, sort: :asc }, # :asc is default
                join: { table: nil, columns: [] },
                action: :update }

    parser = Parser.new
    ast = parser.parse("UPDATE students SET email='k@email.com', age=28 WHERE name='Khalil' ;")

    program = SQlite.new('data/nba_test.db')
    request = program.test(ast)
    expect(request.request).to eq(compare)
  end

end
