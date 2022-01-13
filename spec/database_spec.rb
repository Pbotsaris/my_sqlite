# frozen_string_literal: true

require_relative '../src/database'

describe 'database' do
  it 'rejects search player name' do
    db = Database.new 'data/nba_test.db'
    result = db.player_test.where('Player', 'Carl Braun')

    expect(result[0][1]).to eq('Carl Braun')
  end

  it 'rejects search by height' do
    db = Database.new 'data/nba_test.db'
    result = db.player_test.where('weight', '83')
    result.each { |r| expect(r[3]).to eq('83') }
  end

  it 'rejects search by collage' do
    db = Database.new 'data/nba_test.db'
    result = db.player_test.where('collage', 'Oklahoma State University')
    result.each { |r| expect(r[4]).to eq('Oklahoma State University') }
  end

  it 'rejects searching unexisting column' do
    db = Database.new 'data/nba_test.db'
    result = db.player_test.where('favorite_pet', 'clif')
    expect(result).to eq(nil)
  end

  it 'rejects query not found in column' do
    db = Database.new 'data/nba_test.db'
    result = db.player_test.where('Player', 'Maradonna')
    expect(result).to eq(nil)
  end

  it 'rejects query appending row to table' do
    db = Database.new 'data/nba_test.db'
    row = ['Pedro Botsaris', '66', '66', 'MIT', '1927', 'Sophia', 'New Mexico']
    db.player_test.append(row)
    data = CSV.parse(File.read('data/nba_players_test.csv'), headers: false)
    row[0] = row[0].to_s
    expect(data.last).to eq(row)
  end
end
