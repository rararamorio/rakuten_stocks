module RakutenStocks
  class DomesticStocks
    def initialize(login)
      @encode = login.encode
      @contents = login.stk_pos_mode_login
    end

    def get
      return @contents unless login_status?
      result = {}
      result.merge!(parse_total)
      result.merge!(parse_stock)
      result.merge({status: true})
    end

    private

    def login_status?
      @contents[:status]
    end

    def contents
      @contents[:contents]
    end

    # 時価評価額合計/評価損益額合計
    def parse_total
      result = {}
      result[:appraisal_price_data] = xpath_to_i(contents, "//div[@id='totalAppraisalPriceData']/nobr")
      result[:profit_loss_data] = xpath_to_i(contents, "//div[@id='totalProfitLossData']/nobr")
      {total: result}
    end

    # 口座の内容取得パーサー
    def parse_stock
      result = {}
      # 保有株の一覧を取得
      # 普通口座も入る可能性があるため、テーブルは流動的に取得する
      account_kind = {}
      contents.xpath("//div[@class='caption']/h2[@class='hdg-l1-01-possess']/span").each_with_index do |node, idx|
        account_kind[ idx + 1 ] = node.children.to_s
      end

      account_kind.each do |key, value|
        case value
        when '特定口座'.encode!(@encode) then
          result.merge!(parse_sp(key))
        when 'NISA口座'.encode!(@encode) then
          result.merge!(parse_nisa(key))
        end
      end
      result
    end

    # 特定口座用のパーサー
    def parse_sp(key)
      result = []
      # 特定口座
      sp = contents.xpath("//table[@class='tbl-data-01'][#{key}]")
      sp.xpath("tr[@align='right']").each_with_index do |node, idx|
        stock = Stock.new do |setting|
          setting.code = xpath_children(node, 'td[2]/div/nobr')
          setting.name = xpath_children(node, 'td[3]/div/a')
          setting.url = xpath_children(node, 'td[3]/div/a/@href')
          setting.lending_fee = xpath_to_f(node, 'td[6]/div/nobr')
          setting.hold = xpath_to_i(node, 'td[7]/div/nobr')
          setting.acquisition_cost = xpath_to_f(node, 'td[8]/div/nobr')
          setting.current_price = xpath_to_f(node, 'td[9]/div/nobr')
          setting.market_price = xpath_to_f(node, 'td[10]/div/nobr')
          setting.profits_and_loses = xpath_to_f(node, 'td[11]/div[1]/nobr/span')
          setting.profits_and_loses_rate = xpath_to_f(node, 'td[11]/div[2]/nobr/span')
        end
        result.push stock
      end
      {sp: result}
    end

    # NISA口座用のパーサー
    def parse_nisa(key)
      result = []
      nisa = contents.xpath("//table[@class='tbl-data-01'][#{key}]")
      nisa.xpath("tr[@align='right']").each_with_index do |node, idx|
        stock = Stock.new do |setting|
          setting.code = xpath_children(node, 'td[2]/div/nobr')
          setting.name = xpath_children(node, 'td[3]/div/a')
          setting.url = xpath_children(node, 'td[3]/div/a/@href')
          setting.hold = xpath_to_i(node, 'td[4]/div/nobr')
          setting.acquisition_cost = xpath_to_f(node, 'td[5]/div/nobr')
          setting.current_price = xpath_to_f(node, 'td[6]/div/nobr')
          setting.market_price = xpath_to_f(node, 'td[7]/div/nobr')
          setting.profits_and_loses = xpath_to_f(node, 'td[8]/div[1]/nobr/span')
          setting.profits_and_loses_rate = xpath_to_f(node, 'td[8]/div[2]/nobr/span')
        end
        result.push stock
      end
      {nisa: result}
    end
  end
end
