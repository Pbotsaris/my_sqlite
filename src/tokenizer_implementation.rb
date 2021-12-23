# frozen_string_literal: true

module TokenizerImplementation
  # private implementation for the Tokenizer class
  SPEC = [
    [/^\s+/, nil],              # whitespace
    [/--.*/, nil],              # comments
    [/^\n/, nil],               # linebreak
    [%r{^/\*[\s\S]*?\*/}, nil], # multiline comments
    [/^;/, ';'],                # statements sep
    [/^,/, ','],                # identifier sep

    [/^from/im, 'FROM'],
    [/^select/im, 'SELECT'],
    [/^update/im, 'UPDATE'],
    [/^insert into/im, 'INSERT'],
    [/^delete/im, 'DELETE'],

    [/^\d+/, 'NUMBER'],
    [/^"[^"]*/, 'STRING'],
    [/^'[^']*/, 'STRING'],
    [/^=/, 'ASSIGN'],
    [/\w+|\*/, 'IDENTIFIER']   # will also match the * wildcard
  ].freeze

  def match(regex, line)
    matched = line.match(regex)
    return nil unless matched

    @cursor += matched[0].length
    matched[0]
  end
end
