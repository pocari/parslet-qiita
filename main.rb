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

  rule(:exp) { (number.as(:left) >> (exp_op >> number.as(:right)).repeat).as(:exp) }
  rule(:exp_op) { match('[+-]').as(:op) >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:exp)
end

# 数値用クラス
NumericNode = Struct.new(:value) do
  def eval
    value.to_f
  end
end

# 二項演算用クラス
BinOpNode = Struct.new(:left, :op, :right) do
  def eval
    l = left.eval
    r = right.eval
    case op
    when '-'
      l - r
    when '+'
      l + r
    else
      raise "予期しない演算子です. #{op}"
    end
  end
end

class CalcTransform < Parslet::Transform
  rule(number: simple(:x)) { NumericNode.new(x) }
  # left: xxxの構造も xxxに変換する
  rule(left: simple(:x)) { x }
  rule(exp: subtree(:tree)) {
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

parsed = CalcParser.new.parse('1 - 2 + 3')
p parsed
# => {:exp=>[{:left=>{:number=>"1"@0}}, {:op=>"-"@2, :right=>{:number=>"2"@4}}, {:op=>"+"@6, :right=>{:number=>"3"@8}}]}

ast = CalcTransform.new.apply(parsed)
p ast
# => #<struct BinOpNode left=#<struct BinOpNode left=#<struct NumericNode value="1"@0>, op="-"@2, right=#<struct NumericNode value="2"@4>>, op="+"@6, right=#<struct NumericNode value="3"@8>>

p ast.eval
# => 2.0

