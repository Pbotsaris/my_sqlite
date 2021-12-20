# frozen_string_literal: true

# private implementation for the Tokenizer class
module TokenizerImplementation
  SPEC = [

    [/^\s+/, nil],              # whitespace
    [/--.*/, nil],              # comments
    [/^\n/, nil],               # linebreak
    [%r{^/\*[\s\S]*?\*/}, nil], # multiline comments
    [/^;/, ';'],                # statements sep
    [/^\d+/, 'NUMBER'],
    [/^"[^"]*/, 'STRING'],
    [/^'[^']*/, 'STRING']

  ].freeze

  def match(regex, line)
    matched = line.match(regex)
    return nil unless matched

    @cursor += matched[0].length
    matched[0]
  end
end
