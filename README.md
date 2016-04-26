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

# initialize
rakuten = RakutenStocks::Client.new do |config|
  config.id = 'YourId'
  config.pwd = 'YourPWD'
  config.encode = 'UTF-8' # UTF-8 or EUC-JP
  config.user_agent_alias = 'Windows Mozilla' # README: http://mechanize.rubyforge.org/Mechanize.html#5Buntitled-5D
end

p rakuten.domestic_stocks #=> {:status=>true,:total=>{:appraisal_price_data=>..., :profit_loss_data=>...},:sp=>[...],:nisa=>[...]}
```
