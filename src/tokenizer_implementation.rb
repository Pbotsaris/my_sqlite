# frozen_string_literal: true

# private implementation for the Tokenizer class
module TokenizerImplementation
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
    [/^values/im, 'VALUES'],
    [/^set/im, 'SET'],
    [/^where/im, 'WHERE'],
    [/^order by/im, 'ORDER'],
    [/^asc|^desc/im, 'ORDER_OPTION'],

    [/^\d+/, 'NUMBER'],
    [/^"[^"]*/, 'STRING'],
    [/^'[^']*/, 'STRING'],
    [/^=/, 'ASSIGN'],
    [/^\([^)]*/, 'PARAMS'], # index 16 see below
    [/\w+|\*/, 'IDENTIFIER'] # will also match the * wildcard
  ].freeze

  PARAMS_REGEX = /^\([^)]*/.freeze

  def match(regex, line)
    matched = line.match(regex)

    return nil unless matched

    matched_string = matched[0]
    matched_string = regex == PARAMS_REGEX ? matched_string[1..-1] : matched_string # remove parenthesis from PARAMS

    @cursor += matched_string.length
    matched_string
  end
end
