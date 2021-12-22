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

    [/^\d+/, 'NUMBER'],
    [/^"[^"]*/, 'STRING'],
    [/^'[^']*/, 'STRING'],
    [/^=/, 'ASSIGN'],
    [/\w+/, 'IDENTIFIER']
  ].freeze

  def match(regex, line)
    matched = line.match(regex)
    return nil unless matched

    @cursor += matched[0].length
    matched[0]
  end
end
