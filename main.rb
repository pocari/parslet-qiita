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
    (sign.maybe >> integer >> decimal.maybe).as(:number) >> space?
  }

  rule(:term) { (number.as(:left) >> (term_op >> number.as(:right)).repeat).as(:term) }
  rule(:term_op) { match('[+-]').as(:op) >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:term)
end

# 二項演算用クラス
BinOpNode = Struct.new(:left, :op, :right)

class CalcTransform < Parslet::Transform
  rule(number: simple(:x)) { x.to_f }
  # left: xxxの構造も xxxに変換する
  rule(left: simple(:x)) { x }
  rule(term: subtree(:tree)) {
    if tree.is_a?(Array)
      # 配列ならBinOpNodeに変換
      tree.inject do |left, op_right|
        # 演算子と右辺を取り出し
        op = op_right[:op]
        right = op_right[:right]
        BinOpNode.new(left, op, right)
      end
    else
      # 配列でないならそのものを返す
      tree
    end
  }
end

parsed = CalcParser.new.parse('1 + 2 - 3')
p parsed
# => {:term=>[{:left=>{:number=>"1"@0}}, {:op=>"+"@2, :right=>{:number=>"2"@4}}, {:op=>"-"@6, :right=>{:number=>"3"@8}}]}

p CalcTransform.new.apply(parsed)
# => #<struct BinOpNode left=#<struct BinOpNode left=1.0, op="+"@2, right=2.0>, op="-"@6, right=3.0>
