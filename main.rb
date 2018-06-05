require 'parslet'

class NumParser < Parslet::Parser
  rule(:sign) { match('[-+]').maybe }
  rule(:integer) {
    (match('[1-9]') >> match('[0-9]').repeat) |
    match('[0-9]')
  }
  rule(:decimal) {
    str('.') >> match('[0-9]').repeat
  }
end

p NumParser.new.decimal.parse('.0')
# => ".0"@0
p NumParser.new.decimal.parse('.12')
# => ".12"@0
p NumParser.new.decimal.parse('.001')
# => ".001"@0
