require 'parslet'

class NumParser < Parslet::Parser
  rule(:sign) { match('[-+]') }
  rule(:integer) {
    (match('[1-9]') >> match('[0-9]').repeat) |
    match('[0-9]')
  }
  rule(:decimal) {
    str('.') >> match('[0-9]').repeat
  }
  rule(:number) {
    sign.maybe >> integer >> decimal.maybe
  }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:number)
end

