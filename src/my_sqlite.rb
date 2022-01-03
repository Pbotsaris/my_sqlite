# frozen_string_literal: true

require 'readline'


"random thing"

# a class
class SQlite
  def run
    while (line = Readline.readline('>', true))
      @line = line
    end
  end
end

# SQlite.new.run
