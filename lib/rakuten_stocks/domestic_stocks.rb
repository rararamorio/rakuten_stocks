module RakutenStocks
  class DomesticStocks
    def initialize(contents, encode)
      @contents = contents
      @encode = encode
    end

    def get
      result = {}
      result.merge!(parse_total)
      result.merge!(parse_stock)
      result
    end

    # 時価評価額合計/評価損益額合計
    def parse_total
      result = {}
      result[:appraisal_price_data] = xpath_to_i(@contents, "//div[@id='totalAppraisalPriceData']/nobr")
      result[:profit_loss_data] = xpath_to_i(@contents, "//div[@id='totalProfitLossData']/nobr")
      {total: result}
    end

    # 口座の内容取得パーサー
    def parse_stock
      result = {}
      # 保有株の一覧を取得
      # 普通口座も入る可能性があるため、テーブルは流動的に取得する
      account_kind = {}
      @contents.xpath("//div[@class='caption']/h2[@class='hdg-l1-01-possess']/span").each_with_index do |node, idx|
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
      sp = @contents.xpath("//table[@class='tbl-data-01'][#{key}]")
      sp.xpath("tr[@align='right']").each_with_index do |node, idx|
        stock = Stock.new
        stock.code = xpath_children(node, 'td[2]/div/nobr')
        stock.name = xpath_children(node, 'td[3]/div/a')
        stock.url = xpath_children(node, 'td[3]/div/a/@href')
        stock.lending_fee = xpath_to_f(node, 'td[6]/div/nobr')
        stock.hold = xpath_to_i(node, 'td[7]/div/nobr')
        stock.acquisition_cost = xpath_to_f(node, 'td[8]/div/nobr')
        stock.current_price = xpath_to_f(node, 'td[9]/div/nobr')
        stock.market_price = xpath_to_f(node, 'td[10]/div/nobr')
        stock.profits_and_loses = xpath_to_f(node, 'td[11]/div[1]/nobr/span')
        stock.profits_and_loses_rate = xpath_to_f(node, 'td[11]/div[2]/nobr/span')

        result.push stock
      end
      {sp: result}
    end

    # NISA口座用のパーサー
    def parse_nisa(key)
      result = []
      nisa = @contents.xpath("//table[@class='tbl-data-01'][#{key}]")
      nisa.xpath("tr[@align='right']").each_with_index do |node, idx|
        stock = Stock.new
        stock.code = xpath_children(node, 'td[2]/div/nobr')
        stock.name = xpath_children(node, 'td[3]/div/a')
        stock.url = xpath_children(node, 'td[3]/div/a/@href')
        stock.hold = xpath_to_i(node, 'td[4]/div/nobr')
        stock.acquisition_cost = xpath_to_f(node, 'td[5]/div/nobr')
        stock.current_price = xpath_to_f(node, 'td[6]/div/nobr')
        stock.market_price = xpath_to_f(node, 'td[7]/div/nobr')
        stock.profits_and_loses = xpath_to_f(node, 'td[8]/div[1]/nobr/span')
        stock.profits_and_loses_rate = xpath_to_f(node, 'td[8]/div[2]/nobr/span')

        result.push stock
      end
      {nisa: result}
    end

    def xpath_to_f(node, xpath)
      xpath_children(node, xpath).strip.gsub(',', '').gsub('%', '').to_f
    end

    def xpath_to_i(node, xpath)
      xpath_children(node, xpath).strip.gsub(',', '').to_i
    end

    def xpath_children(node, xpath)
      node.xpath(xpath).children.to_s
    end
  end
end
