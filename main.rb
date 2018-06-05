require 'parslet'

class NumParser < Parslet::Parser
  rule(:sign) { match('[-+]').maybe }
end

p NumParser.new.sign.parse('-')
p NumParser.new.sign.parse('+')
p NumParser.new.sign.parse('')
