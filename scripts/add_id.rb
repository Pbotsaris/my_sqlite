require 'csv'

rows = CSV.read(ARGV[0], headers: true)

headers = rows[0].map { |key, _pair| key }

headers.unshift(nil)

CSV.open('new_nba_data.csv', 'wb') do |csv|
  csv << headers

  rows.each_with_index do |row, i|
    row_array = row.map { |_key, value| value }
    row_array.unshift(i) # id starts for 1
    csv << row_array
  end
end
