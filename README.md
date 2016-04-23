# RakutenStocks(楽天証券国内保有株スクレイピング)

## Installation

Add this line to your application's Gemfile:

※ 今のところgemの登録はする予定無いので、以下を実行してもインストールはされないです。

```ruby
gem 'rakuten_stocks'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rakuten_stocks

## Usage

```ruby
require 'rakuten_stocks'

rakuten = RakutenStocks::Client.new('YourId', 'YourPwd')
p rakuten.domestic_stocks #=> {:status=>'succeeded',:total=>{:appraisal_price_data=>..., :profit_loss_data=>...},:sp=>[...],:nisa=>[...]}
```
