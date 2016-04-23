module RakutenStocks
  class Stock
      attr_accessor :code,                  # 銘柄コード
                    :name,                  # 銘柄名
                    :url,                   # 銘柄(詳細ページURL)
                    :lending_fee,           # 貸株金利
                    :hold,                  # 保有数量
                    :acquisition_cost,      # 平均取得価格
                    :current_price,         # 現在値
                    :market_price,          # 時価評価額
                    :profits_and_loses,     # 評価損益
                    :profits_and_loses_rate # 評価損益率
  end
end
