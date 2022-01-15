# frozen_string_literal: true

require_relative '../src/database'
require 'fileutils'

db = Database.new 'data/nba_test.db'

describe 'database' do
  it 'rejects search player name' do
    result = db.player_test.find('Player', 'Carl Braun')

    expect(result[0][1]).to eq('Carl Braun')
  end

  it 'rejects search by height' do
    result = db.player_test.find('weight', '83')
    result.each { |r| expect(r[3]).to eq('83') }
  end

  it 'rejects search by collage' do
    result = db.player_test.find('collage', 'Oklahoma State University')
    result.each { |r| expect(r[4]).to eq('Oklahoma State University') }
  end

  it 'rejects searching unexisting column' do
    result = db.player_test.find('favorite_pet', 'clif')
    expect(result).to eq(nil)
  end

  it 'rejects query not found in column' do
    result = db.player_test.find('Player', 'Maradonna')
    expect(result).to eq(nil)
  end

  it 'rejects appending row to table' do
    row = ['Pedro Botsaris', '66', '66', 'MIT', '1927', 'Sophia', 'New Mexico']
    db.player_test.append(row)
    data = CSV.parse(File.read('data/nba_players_test.csv'), headers: false)
    row[0] = row[0].to_s
    expect(data.last).to eq(row)
    # this tests if inserting a new row adds to index and thus making the row searchable
    result = db.player_test.find('Player', 'Pedro Botsaris')

    expect(result[0]).to eq(row)

    restore_test_file
  end

  it 'rejects updating row with where' do
    where = { column: 'Player', term: 'Gene Englund' }
    values = [{ column: 'Player', value: 'Jose Marcos' }, { column: 'birth_state', value: 'indiana' }]

    db.player_test.update(values, where)
    result = db.player_test.find('Player', 'Jose Marcos')

    unless result.nil?
      result = result.flatten
      expect(result[1]).to eq('Jose Marcos')
    end

    restore_test_file
  end

  it 'rejects updating index TRIE when updating db' do
    where = { column: 'Player', term: 'Gene Englund' }
    values = [{ column: 'Player', value: 'Jose Marcos' }, { column: 'birth_state', value: 'indiana' }]

    db.player_test.update(values, where)
    result = db.player_test.find('Player', 'Gene Englund')

    expect(result).to eq(nil)

    restore_test_file
  end

  it 'rejects deleting single row with where' do
    result = db.player_test.find('Player', 'Don Carlson')
    expect(result[0][1]).to eq('Don Carlson')

    db.player_test.delete('Player', 'Don Carlson')
    result = db.player_test.find('Player', 'Don Carlson')

    expect(result).to eq(nil)

    restore_test_file
  end

  it 'rejects deleting multiple rows with where' do
    result = db.player_test.find('height', '180')

    expect(result).to be_truthy

    db.player_test.delete('height', '180')
    result = db.player_test.find('height', '180')
    # expect(result).to eq(nil)

    expect(result).to eq(nil)
    restore_test_file
  end
end

# restores the test file to original after tests

def restore_test_file
  path = 'data/nba_players_test.csv'
  File.delete(path)
  FileUtils.cp('data/nba_players_test-backup.csv', path)
end
