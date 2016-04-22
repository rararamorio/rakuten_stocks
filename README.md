# 楽天証券のスクレイピング

## 目的

* 自分が購入している株の一覧を取得したかったので、取りあえず作成
* mechanize + nokogiri でのスクレイピングを行ってみたかった(技術検証的な部分)

## 使用方法

* gem のように使用できるようには作っていないので、適宜requireしてください。

例としては、、、

```
require './RakutenStock'

rakuten = RakutenStock.new('ユーザID', 'パスワード')
p rakuten.get_stocks

```