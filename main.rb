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

  rule(:term) { number.as(:left) >> (term_op.as(:op) >> number.as(:right)).repeat }
  rule(:term_op) { match('[+-]') >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:term)
end

p CalcParser.new.parse('1 + 2 - 3')
# => [{:left=>"1 "@0}, {:op=>"+ "@2, :right=>"2 "@4}, {:op=>"- "@6, :right=>"3"@8}]
