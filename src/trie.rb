# frozen_string_literal: true

require 'pp'

module Constants
  OFFSET = 32
  ASCII_MAX = 128
  MAX_CHARS = Constants::ASCII_MAX - Constants::OFFSET
end

# a node
class Node
  include Constants

  attr_accessor :is_word, :id, :word
  attr_reader :value, :next

  def initialize(id)
    @next = create_next
    @is_word = false
    @id = [id]
  end

  def create_next
    next_nodes = []
    MAX_CHARS.times { next_nodes.append(nil) }
    next_nodes
  end
end

# a Trie
class Trie
  include Constants
  def initialize
    @root = Node.new('a')
  end

  def find(word)
    charlist = word.split('')
    current = @root

    charlist.each_with_index do |char, i|
      index = char.ord - OFFSET

      return nil if current.next[index].nil?

      return current.next[index] if found_word?(current.next[index], word, i)

      current = current.next[index]
    end
  end

  def insert(id, word)
    charlist = word.split('')
    current = @root

    charlist.each do |char|
      index = char.ord - OFFSET
      current.next[index] = Node.new(id) if current.next[index].nil?

      current = current.next[index]
    end

    create_word(current, word, id)
  end

  private

  def found_word?(node, word, index)
    node.is_word && index == word.length - 1
  end

  def create_word(node, word, id)
    if node.is_word
      node.id.append(id)
      return
    end

    node.is_word = true
    node.word = word
  end
end

trie = Trie.new

# trie.insert('pedro')
trie.insert(1, 'jose')
trie.insert(2, 'jose')
node = trie.find('jose')
p node.word, node.id unless node.nil?


#  id              name                age
#
#   [id_trie, name_trie, age_trie]
#   { columns: [trie], entries: [ {id: 1}] }
