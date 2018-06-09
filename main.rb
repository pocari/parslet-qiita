require 'parslet'

class CalcParser < Parslet::Parser
  rule(:sign) { match('[-+]') }
  rule(:integer) {
    (match('[1-9]') >> match('[0-9]').repeat) |
    match('[0-9]')
  }
  rule(:decimal) {
    str('.') >> match('[0-9]').repeat(1)
  }
  rule(:number) {
    (sign.maybe >> integer >> decimal.maybe).as(:number) >> space?
  }
  rule(:expression) {
    infix_expression(
      number,
      [term_op, 10, :left],
      [exp_op, 5, :left],
    )
  }

  rule(:exp_op) { match('[+-]') >> space? }
  rule(:term_op) { match('[*/]') >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  root(:expression)
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
    when '*'
      l * r
    when '/'
      l / r
    else
      raise "予期しない演算子です. #{op}"
    end
  end
end

class CalcTransform < Parslet::Transform
  rule(number: simple(:x)) { NumericNode.new(x) }
  rule(left: simple(:x)) { x }

  rule(
    l: simple(:l),
    o: simple(:o),
    r: simple(:r)
  ) {
    BinOpNode.new(l, o.to_s.strip, r)
  }
end

parsed = CalcParser.new.parse('1 + 2 * 3 / 6 - 4')
p parsed
# => {:l=>{:l=>{:number=>"1"@0}, :o=>"+ "@2, :r=>{:l=>{:l=>{:number=>"2"@4}, :o=>"* "@6, :r=>{:number=>"3"@8}}, :o=>"/ "@10, :r=>{:number=>"6"@12}}}, :o=>"- "@14, :r=>{:number=>"4"@16}}
ast = CalcTransform.new.apply(parsed)
p ast
# => <struct BinOpNode left=#<struct BinOpNode left=#<struct NumericNode value="1"@0>, op="+", right=#<struct BinOpNode left=#<struct BinOpNode left=#<struct NumericNode value="2"@4>, op="*", right=#<struct NumericNode value="3"@8>>, op="/", right=#<struct NumericNode value="6"@12>>>, op="-", right=#<struct NumericNode value="4"@16>>

p ast.eval
# => -2.0

