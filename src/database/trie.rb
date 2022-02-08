# frozen_string_literal: true

module Constants
  OFFSET = 32
  ASCII_MAX = 128
  MAX_CHARS = Constants::ASCII_MAX - Constants::OFFSET
end

# A a TRIE node with MAX_CHARS branches
class Node
  include Constants

  attr_accessor :is_word, :id, :word
  attr_reader :value, :next
  alias is_word? is_word

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

# a Trie to search words that returns a node
# The node contains the primary key in database
class Trie
  include Constants

  attr_accessor :root

  def initialize
    @root = Node.new('a')
  end

  # finds a word in the TRIE
  def find(word)
    return nil if word.nil?

    charlist = word.split('')
    current = @root

    charlist.each_with_index do |char, i|
      index = char.ord - OFFSET

      return nil if current.next[index].nil?

      return current.next[index] if found_word?(current.next[index], word, i)

      current = current.next[index]
    end
    nil
  end

  # Updates a node.id in the TRIE with a new_id.  If node does not have any id left
  # remove word from TRIE. It does not clear references in the tree
  def update(id, new_id, word)
    return nil if word.nil?

    node = find(word)
    node.id = node.id.reject { |i| i == id }
    node.id << new_id
  end

  #  Deletes a node.id in the TRIE
  def delete(id, word)
    return nil if word.nil?

    node = find(word)
    node.id = node.id.reject { |i| i == id }
    node.is_word = false if node.id.empty?
  end

  # Deletes word for TRIE. It does not clear the references in the tree, however.
  def delete_all(word)
    node = find(word)
    node.id = []
    node.is_word = false
  end

  #  Inserts a node to the TRIE
  def insert(id, word)
    return if word.nil?

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
