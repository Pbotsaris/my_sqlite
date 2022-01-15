# frozen_string_literal: true

require_relative '../src/trie'

describe 'tries' do
  it 'rejects insert and find node' do
    name = 'jose'
    compare = Node.new('s')
    compare.is_word = true
    compare.id = [1]
    compare.word = name

    trie = Trie.new
    trie.insert(1, name)
    node = trie.find(name)
    expect(node.word).to eq(compare.word)
    expect(node.is_word?).to eq(compare.is_word?)
    expect(node.id[0]).to eq(compare.id[0])
  end

  it 'rejects inserting duplicated words' do
    name = 'jose'

    trie = Trie.new
    trie.insert(1, name)
    trie.insert(2, name)
    trie.insert(10, name)

    node = trie.find(name)
    expect(node.id[0]).to eq(1)
    expect(node.id[1]).to eq(2)
    expect(node.id[2]).to eq(10)
  end

  it 'rejects inserting words with same chars' do
    name = 'jose'
    name2 = 'josemo'

    trie = Trie.new
    trie.insert(1, name)
    trie.insert(2, name2)
    node = trie.find(name)
    expect(node.word).to eq(name)
    expect(node.id[0]).to eq(1)
    node = trie.find(name2)
    expect(node.word).to eq(name2)
    expect(node.id[0]).to eq(2)
  end

  it 'rejects updating the id of a word' do
    name = 'jose'

    trie = Trie.new
    trie.insert(1, name)
    trie.insert(2, name)

    trie.update(1, 10, name)
    node = trie.find(name)

    expect(node.id).to eq([2, 10])
  end

  it 'rejects deleting id of a word' do
    name = 'jose'
    trie = Trie.new
    trie.insert(1, name)
    trie.insert(2, name)

    trie.delete(1, name)
    node = trie.find(name)

    expect(node.id).to eq([2])
  end

  it 'rejects delete a word with delete' do
    name = 'jose'
    trie = Trie.new
    trie.insert(1, name)

    trie.delete(1, name)
    node = trie.find(name)

    expect(node).to eq(nil)
  end

  it 'rejects deleting a word with delete_all' do
    name = 'jose'
    trie = Trie.new
    trie.insert(1, name)
    trie.insert(2, name)

    trie.delete_all(name)
    node = trie.find(name)

    expect(node).to eq(nil)
  end
end
