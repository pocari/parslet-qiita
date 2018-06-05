require 'parslet'

class CalcParser < Parslet::Parser
  rule(:sign) { match('[-+]') }
  rule(:integer) {
    (match('[1-9]') >> match('[0-9]').repeat) |
    match('[0-9]')
  }
  rule(:decimal) {
    str('.') >> match('[0-9]').repeat
  }
  rule(:number) {
    sign.maybe >> integer >> decimal.maybe >> space?
  }
  rule(:term) { number >> (term_op >> number).repeat }
  rule(:term_op) { match('[+-]') >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:term)
end

p CalcParser.new.parse('1+2-3')
# => "1+2-3"@0
p CalcParser.new.parse('1+2-')
# => Parslet::ParseFailed -の項が足りないのでエラーが出る
#
