# RakutenStocks(楽天証券の国内株スクレイピング)

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
p rakuten.get_stocks

==<< 出力内容 >>==
{
  :total=>{
    :appraisal_price_data=>123456789, # 時価評価額合計
    :profit_loss_data=>123456789      # 評価損益額合計
  },
  # 特定口座
  :sp=>{
    "12345"=>{
      :code=>"12345",                         # 銘柄コード
      :name=>"銘柄名",                         # 銘柄名
      :url=>"",                               # 銘柄詳細ページURL
      :loan_stock=>0.1,                       # 貸株金利
      :amount=>100,                           # 保有数量
      :acquisition_price=>1234.12,            # 平均取得価格
      :unit_price=>1234.0,                    # 現在値
      :market_value=>123456789.0,             # 時価評価額
      :unrealized_profits_and_loses=>12345.0, # 評価損益
      :unrealized_profits_and_loses_rate=>0.1 # 評価損益率
    },{...}
  },
  # NISA口座(構成は特定口座と同じだが、loan_stockは存在しない)
  :nisa=>{
    ...
  }
}
==>> 出力内容 <<==
```
