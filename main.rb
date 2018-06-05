require 'parslet'

class NumParser < Parslet::Parser
  rule(:sign) { match('[-+]').maybe }
  rule(:integer) {
    (match('[1-9]') >> match('[0-9]').repeat) |
    match('[0-9]')
  }
end

p NumParser.new.integer.parse('0')
# => "0"@@
p NumParser.new.integer.parse('10')
# => "10"@@
p NumParser.new.integer.parse('01')
# => Parslet::ParseFailed パース失敗
