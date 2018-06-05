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
    # 数値部分に対して :number でキャプチャする
    (sign.maybe >> integer >> decimal.maybe).as(:number) >> space?
  }

  # 数値や演算子は各レベルでキャプチャしているので、ここでは左辺、右辺のキャプチャのみ
  rule(:term) { number.as(:left) >> (term_op >> number.as(:right)).repeat }
  # 演算子に対して :op でキャプチャする
  rule(:term_op) { match('[+-]').as(:op) >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:term)
end

# 追加したTransformクラス
class CalcTransform < Parslet::Transform
  rule(number: simple(:x)) { x.to_f }
end

# まずパースする
parsed = CalcParser.new.parse('1 + 2 - 3')
# パース結果表示
p parsed
# => [{:left=>{:number=>"1"@0}}, {:op=>"+"@2, :right=>{:number=>"2"@4}}, {:op=>"-"@6, :right=>{:number=>"3"@8}}]

# パース結果をtransformした結果を表示
p CalcTransform.new.apply(parsed)
# => [{:left=>1.0}, {:op=>"+"@2, :right=>2.0}, {:op=>"-"@6, :right=>3.0}]

