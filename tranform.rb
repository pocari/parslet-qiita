require 'parslet'

class TransformTest < Parslet::Transform
  # 確認のために同一のキーで各typeを定義してその内容(x)をそのままダンプする
  rule(k1: simple(:x)) {
    puts("match simple")
    p x
  }
  rule(k1: sequence(:x)) {
    puts("match sequene")
    p x
  }
  # これをk1で定義してしまうと全部このルールにマッチしてしまうため
  # これだけk2で定義する
  rule(k2: subtree(:x)) {
    puts("match subtree")
    p x
  }

  # 下記のようにt1、t2それぞれのキーに対してそれぞれの種類でマッチする
  # ようなルールも作成できる
  rule(
    t1: simple(:x),
    t2: sequence(:y)
  ) {
    puts ('match simple t1 and sequnece h2')
    p x
    p y
  }
end

TransformTest.new.apply({ k1: 'aaa' })
# => match simple
#    "aaa"

TransformTest.new.apply({ k1: ['a1', 'a2', 'a3'] })
# => match sequene
#   ["a1", "a2", "a3"]

TransformTest.new.apply({ k2: { inner_k: 'hoge'} })
# => match subtree
#   {:inner_k=>"hoge"}

TransformTest.new.apply({ t1: 'aaa', t2: ['b1', 'b2'] })
# => match simple t1 and sequnece h2
#   "aaa"
#   ["b1", "b2"]
