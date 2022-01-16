# frozen_string_literal: true

# a request
class Request
  attr_reader :request, :valid, :complete
  alias valid? valid
  alias complete? complete

  def initialize
    @request = _init_request
    @valid = true
    @complete = false
  end

  def reset
    @request = _init_request
  end

  def from(table)
    @request[:table] = table
  end

  # columns is an array
  def select(columns)
    @request[:columns] = columns
    @request[:action] = :select
  end

  def insert(table)
    @request[:table] = table
    @request[:action] = :insert
  end

  def update(table)
    @request[:table] = table
    @request[:action] = :update
  end

  def delete
    @request[:action] = :delete
    @request[:columns] = ['*']
  end

  # values = array
  def values(values)
    @request[:values] = values
    @request[:columns] = ['*']
  end

  # columns and values are arrays
  def set(columns, values)
    @request[:columns] = columns
    @request[:values] = values
  end

  def where(columns, values)
    where = columns.each_with_index.map { |column, i| { column: column, term: values[i] } }

    @request[:where] = where
  end

  def order(columns, option)
    @request[:order] = { columns: columns, sort: option ? option.downcase.to_sym : :asc }
  end

  def join(table)
    @request[:join] = { table: table, columns: ['*'] }
  end

  def on(columns)
    @request[:join][:columns] = columns
  end

  private

  def _init_request
    { table: nil, columns: [], values: [], where: [], order: {}, join: {}, action: nil }
  end
end
